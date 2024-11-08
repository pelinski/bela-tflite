#!/bin/bash
source TF_VERSION.env
mkdir tflite-install && tar -xvf tflite-install.tar -C tflite-install
mv tflite-install/workspace/tensorflow/tensorflow/lite/tflite-${TF_VERSION}.tar.gz ./
rm -rf tflite-install