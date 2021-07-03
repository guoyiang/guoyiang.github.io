---
title: Build My Own Raspbian Docker Image
date: 2016-11-04 21:59:58
tags: 
	- Docker
	- Raspberry Pi
---

It's great to have Docker on Raspberry Pi, and there's a [blog][RPi-Docker-Blog] about it.

# Update 2021

After so many years, the ecosystem has evolved a lot. Docker supports [multi-CPU architecture](https://docs.docker.com/desktop/multi-arch/) so does many images, e.g. [alpine](https://hub.docker.com/_/alpine). It's no longer needed to do those complex steps by yourself.

# Previous Blog

But one thing I found is that Raspberry Pi is based on ARM CPU, thus do not support x86/x64 instructions. **Any Docker image build for x86/x64 won't work**. And, I didn't find any **official** Docker image built for Raspberry Pi. [resin/rpi-raspbian][Resin-Docker] is widely used and also used by [Docker][Resin-Used-in-Docker] project is a good candidate and is lightweitht, but I still want to use an official one. So, I decided to build one myself.
<!--more-->

# Download Raspbian

I have done this already, [download][Raspbian-Download] and unzip the image. Now I got `2016-09-23-raspbian-jessie-lite.img`. 

# Create a tarball archive containing files from official Raspbian

`2016-09-23-raspbian-jessie-lite.img` is an [IMG file][IMG-File] which contains raw dump of disk, and I can mount it under Linux.

## List the partitions of the img

	```
	[blah@localhost ~]$ fdisk -l ./2016-09-23-raspbian-jessie-lite.img

	Disk ./2016-09-23-raspbian-jessie-lite.img: 1389 MB, 1389363200 bytes, 2713600 sectors
	Units = sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disk label type: dos
	Disk identifier: 0x5a7089a1

	                                Device Boot      Start         End      Blocks   Id  System
	./2016-09-23-raspbian-jessie-lite.img1            8192      137215       64512    c  W95 FAT32 (LBA)
	./2016-09-23-raspbian-jessie-lite.img2          137216     2713599     1288192   83  Linux
	```

Two partitions are listed here, and the second one is the root fs of Raspbian.

## Mount the img using loop device

	```
	[blah@localhost ~]$ sudo losetup -Pr /dev/loop0 2016-09-23-raspbian-jessie-lite.img
	[blah@localhost ~]$ ls /dev/loop0*
	/dev/loop0  /dev/loop0p1  /dev/loop0p2
	[blah@localhost ~]$ mkdir rpi
	[blah@localhost ~]$ sudo mount -o ro /dev/loop0p2 ./rpi
	```

When I list file under rpi directory, I should see all files to root of Raspbian. 

## Archive the filesystem to tarball

Next, I will archive the whole Raspbian file system to a tarball archive to import into Docker image.

	```
	sudo tar -C ./rpi -czpf 2016-09-23-raspbian-jessie-lite.tar.gz --numeric-owner .
	```

This will generate `2016-09-23-raspbian-jessie-lite.tar.gz` under current folder, and preserving all permissions with numeric owner id. I can view the files inside tarball using:

	```
	tar --numeric-owner -tvzf 2016-09-23-raspbian-jessie-lite.tar.gz
	```

And, unmount the devices.

	```Bash
    sudo umount ./rpi
    sudo losetup -d /dev/loop0
    ```

# Create Dockerfile

Now, I can upload the tarball file into Raspberry Pi and create my Docker image. Below is my Dockerfile, and I put `2016-09-23-raspbian-jessie-lite.tar.gz` in the same directory besides Dockerfile.

	```Dockerfile
	FROM scratch
	ADD ./2016-09-23-raspbian-jessie-lite.tar.gz /
	CMD ["/bin/bash"]
	```

Then, I'm just one step away from finish.

	```
	➜  blah@raspberrypi:raspbian git:(master)✗ $ docker build -t blah .
	Sending build context to Docker daemon 290.8 MB
	Step 1 : FROM scratch
	 --->
	Step 2 : ADD ./2016-09-23-raspbian-jessie-lite.tar.gz /
	 ---> Using cache
	 ---> f22314f2ba29
	Step 3 : CMD /bin/bash
	 ---> Using cache
	 ---> 86f8965d6316
	Successfully built 86f8965d6316
	```

Voilà, it's done! The only drawback is size of image. Seems Raspbian shipped with lots of extra packages, the image I created is 694.4 MB.

	```
	➜  blah@raspberrypi:raspbian git:(master)✗ $ docker run -it blah
	root@a6318807be9d:/# echo "hello-world"
	hello-world
	root@a6318807be9d:/#
	```

# Docker Hub

I have pushed it to Docker Hub, if you want to use mine, you can use [guoyiang/raspbian][Docker-Hub-Me] . But I guess you would prefer build your own :)

I also found an interesting Docker repository which has some armhf images to use: [armhf][Docker-Hub-armhf]. Well, Docker/Raspberry Pi Foundation, please provide us some official images.

[RPi-Docker-Blog]: https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/ "Raspberry Pi's blog about Docker"
[Resin-Docker]: https://hub.docker.com/r/resin/rpi-raspbian/ "resin/rpi-raspbian"
[Resin-Used-in-Docker]: https://github.com/docker/docker/blob/master/contrib/builder/deb/armhf/raspbian-jessie/Dockerfile "Resin Docker image used in Docker project"
[Raspbian-Download]: https://www.raspberrypi.org/downloads/raspbian/ "Download Raspbian"
[IMG-File]: https://en.wikipedia.org/wiki/IMG_(file_format) "IMG file"
[Loop-Device]: https://en.wikipedia.org/wiki/Loop_device "Loop device"
[Docker-Hub-Me]: https://hub.docker.com/r/guoyiang/raspbian/ "guoyiang/raspbian"
[Docker-Hub-armhf]: https://hub.docker.com/u/armhf/ "armhf"