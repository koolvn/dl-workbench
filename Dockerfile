FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

LABEL workbench="DL engineer workbench. Ubuntu OpenCV TF2\PyTorch Jupyter"

ARG DEBIAN_FRONTEND="noninteractive"
ARG USER="developer"
ENV OpenCV_version="4.10.0"
ENV OpenCV_install_path="/usr/local/share/opencv-${OpenCV_version}" \
    ARCH="8.6" \
    HOME="/home/${USER}" \
    NOTEBOOK_DIR="/mnt/"

RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates wget curl unzip git cmake graphviz \
    python3-pip python-is-python3 nano vim \
    libopencv-dev build-essential pkg-config \
    yasm libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libxvidcore-dev x264 libx264-dev libmp3lame-dev libtheora-dev \
    libfaac-dev libvorbis-dev python3-testresources \
    libxine2-dev libv4l-dev v4l-utils \
    libgtk-3-dev python3-dev libtbb-dev libatlas-base-dev gfortran \
    libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev \
    libgphoto2-dev libeigen3-dev libhdf5-dev doxygen \
    libcanberra-gtk-module libcanberra-gtk3-module && \
    ln -s -f /usr/include/libv4l1-videodev.h /usr/include/linux/videodev.h && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Python libraries
COPY requirements.txt /distr/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir albumentations[imgaug] --no-binary imgaug,albumentations && \
    pip install --no-cache-dir -r /distr/requirements.txt

# Build OpenCV
COPY build_opencv.sh /distr/opencv/
WORKDIR /distr/opencv
RUN chmod +x build_opencv.sh && ./build_opencv.sh && \
    cd /distr/opencv/opencv-${OpenCV_version}-build-gpu && \
    make -j"$(nproc)" install && rm -rf /distr/opencv && \
    cp /usr/lib/python3/dist-packages/cv2/python-3.10/cv2.cpython-310-x86_64-linux-gnu.so \
       /usr/local/lib/python3.10/dist-packages/cv2/cv2.cpython-310-x86_64-linux-gnu.so

# Install PyTorch
RUN python -m pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

## Install Tensorflow
#RUN python -m pip install --no-cache-dir tensorflow[and-cuda]

# Make container with non-root user securely
RUN useradd -m -u 1000 -o -s /bin/bash ${USER}

# Setup Jupyter and tests
COPY jupyter_notebook_config.py ${HOME}/.jupyter/
COPY tests.py /distr/

# Set proper permissions
RUN chown -R ${USER}:${USER} /distr ${HOME}

USER ${USER}
WORKDIR /distr

# Run tests and start jupyter server
ENTRYPOINT ["sh", "-c", "python tests.py && echo 'Starting Jupyter' && jupyter notebook --notebook-dir=${NOTEBOOK_DIR}"]
