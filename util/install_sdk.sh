#!/bin/bash

FILE='android-sdk_r23.0.2-linux'


default_dir='android-sdk-linux' # The directory that is within the the tarball...
mkdir sdk
cd sdk
wget https://dl.google.com/android/${FILE}.tgz

tar -xzf ${FILE}.tgz
rm ${FILE}.tgz

mv ${default_dir}/* .
rmdir ${default_dir}

./tools/android update sdk --no-ui

cd -
