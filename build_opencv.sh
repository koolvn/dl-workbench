#!/bin/bash

wget -O opencv_"${OpenCV_version}".zip https://github.com/opencv/opencv/archive/"${OpenCV_version}".zip
if [[ $? -ne 0 ]]; then
    echo "Failed to download Opencv $OpenCV_version"
    exit 1
fi

wget -O "opencv_contrib_${OpenCV_version}.zip" "https://github.com/opencv/opencv_contrib/archive/${OpenCV_version}.zip"
if [[ $? -ne 0 ]]; then
    echo "Failed to download Opencv contrib ${OpenCV_version}"
    exit 1
fi

unzip -o -q "opencv_${OpenCV_version}.zip"
if [[ $? -ne 0 ]]; then
    echo "Failed to unzip opencv_$OpenCV_version.zip"
    exit 1
fi

unzip -o -q "opencv_contrib_${OpenCV_version}.zip"
if [[ $? -ne 0 ]]; then
    echo "Failed to unzip opencv_contrib_$OpenCV_version.zip"
    exit 1
fi

mkdir -p opencv-$OpenCV_version-build-gpu && cd opencv-$OpenCV_version-build-gpu
if [[ $? -ne 0 ]]; then
    echo "Failed to create opencv-$OpenCV_version-build-gpu"
    exit 1
fi

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=$OpenCV_install_path \
    -D WITH_TBB=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D WITH_CUBLAS=1 \
    -D WITH_CUDA=ON \
    -D BUILD_opencv_cudacodec=OFF \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D CUDA_ARCH_BIN="$ARCH" \
    -D WITH_V4L=ON \
    -D WITH_QT=OFF \
    -D WITH_OPENGL=ON \
    -D WITH_GSTREAMER=ON \
    -D WITH_FFMPEG=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_PC_FILE_NAME=opencv.pc \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
    -D PYTHON_EXECUTABLE=/usr/bin/python3 \
    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-$OpenCV_version/modules \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ../opencv-$OpenCV_version

if [[ $? -ne 0 ]]; then
    echo "Cmake failed."
    exit 1
fi