# bela-tflite

This repository contains a Dockerfile that builds TFLite for armv7. Instead of cross-compiling with a CMake toolchain, we build TFLite "natively" in armv7 using the `multiarch/qemu-user-static` docker image to emulate an armv7 environment.

## Building TFLite for armv7

You will need to have Docker installed and running. You can install it following the instructions on the [Docker website](https://docs.docker.com/get-docker/).

Before we get started we need to ensure that we can emulate ARM32. We do this by install `qemu` and configuring it:

```bash
# Install QEMU
sudo apt install binfmt-support qemu qemu-user-static

# Configure QEMU to enable execution of different multi-architecture containers by QEMU and binfmt_misc
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

After our prerequisites are done, we can compile TFLite by starting up the docker build process. Be aware that it might take ~5h to compile. You can set the `TF_VERSION` build argument to the version of TFLite you want to build. The default is `main`.

```bash
docker buildx build --build-arg TF_VERSION=main --platform=linux/arm/v7 --progress=plain --output type=tar,dest=tflite-install.tar .
```

This generates a `tflite-install.tar` file that contains all the filesystem from the docker image. The packaged installation is in `workspace/pytorch//pytorch-${TF_VERSION}.tar.gz`. To extract the compiled pytorch, run the following commands:

```bash
source TF_VERSION.env
mkdir tflite-install && tar -xvf tflite-install.tar -C tflite-install
mv tflite-install/workspace/tensorflow/tensorflow/lite/tflite-${TF_VERSION}.tar.gz ./
rm -rf tflite-install
```

or alternatively, `./extract-tflite-install.sh` will do the same.

NOTE: If you have a good computer you can try speed up the build modifying the `-j` flag in the `Dockerfile` to a higher value. You can also try to increase the memory allocated to Docker in the settings. Be aware that errors related to lack of resources are not properly reported in the cmake output. If you increase the `-j` flag and get a cmake error without any message, try to reduce the value back to `-j1`.

## Also check

- [pybela-pytorch-xcompilation tutorial](https://github.com/pelinski/pybela-pytorch-xc-tutorial) - Tutorial on how integrate and crosscompile pytorch code for Bela
- [bela-torch](https://github.com/pelinski/bela-torch) - Build torch for Bela using Docker (+ precompiled binaries)

## Credits

This repo builds on top of https://github.com/rodrigodzf/bela-torch and https://github.com/XavierGeerinck/Jetson-Linux-PyTorch
