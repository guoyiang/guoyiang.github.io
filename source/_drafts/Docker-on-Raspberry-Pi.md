---
title: Docker on Raspberry Pi
date: 2016-11-04 21:38:41
tags: 
	- Docker
	- Raspberry Pi
---
# Install Docker on Raspbian

Login to raspberry pi via SSH or terminal, and run:

	curl -sSL https://get.docker.com/ | sh

This will install docker on system. After successful, you should be able to run `docker` from command line.

# Start Docker container

The next step 



Check the log on screen if the repository URL added to `/etc/apt/sources.list.d/docker.list` is as following:

	deb [arch=armhf] https://apt.dockerproject.org/repo raspbian-jessie main

On my setup, the script used the debian repository instead of raspbian one, causing Hash Sum mismatch error. To fix this, I manually 