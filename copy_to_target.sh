#!/bin/bash
#Clear the target folder and copy all contents there, so npm install can run. It's because CIFS mounted windows shared folder do not support symbolic link, which fails npm install.

TARGET_FOLDER=/home/guoyiang/homepage_files

shopt -s extglob

find $TARGET_FOLDER -maxdepth 1 -mindepth 1 ! -name "node_modules" -exec rm -Rf {} \;
#find . -maxdepth 1 -mindepth 1 ! -name "node_modules" ! -name ".git" ! -name ".gitignore" -exec cp -R {} $TARGET_FOLDER \;
cp -R !(node_modules|\.git|\.gitignore) $TARGET_FOLDER