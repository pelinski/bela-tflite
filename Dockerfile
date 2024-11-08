FROM debian:bullseye as downloader
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y git 

WORKDIR /workspace

ARG TF_VERSION
RUN git clone --recursive --branch ${TF_VERSION} https://github.com/tensorflow/tensorflow.git

FROM debian:bullseye as builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y  git build-essential cmake

COPY --from=downloader /workspace/tensorflow /workspace/tensorflow

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "running on $BUILDPLATFORM, building for $TARGETPLATFORM" 

ARG TF_VERSION
RUN echo "Building TFLite version ${TF_VERSION}"
 

RUN mkdir -p /workspace/tensorflow/tensorflow/lite/build && cd /workspace/tensorflow/tensorflow/lite/build && \
    cmake .. \
    -DTFLITE_ENABLE_XNNPACK=OFF

RUN cd /workspace/tensorflow/tensorflow/lite/build && cmake --build . -j1

RUN cd /workspace/tensorflow/tensorflow/lite/build && cmake --install . --prefix /workspace/tensorflow/tensorflow/lite/install --config Release

RUN cd /workspace/tensorflow/tensorflow/lite/install && tar -czf /workspace/tensorflow/tensorflow/lite/tflite-${TF_VERSION}.tar.gz .
