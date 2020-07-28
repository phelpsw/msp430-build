FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    meson \
    wget \
    unzip \
    build-essential \
    libusb-dev \
    libreadline-dev \
    libboost1.67 \
    pkg-config \
    libudev1 \
    libudev-dev \
    libusb-1.0-0-dev \
    libncursesw5 \
    git

RUN wget -q -O toolchain.tar.bz2 http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-9.2.0.50_linux64.tar.bz2 && \
    tar xjf toolchain.tar.bz2 && \
    mv /msp430-gcc-9.2.0.50_linux64/ /usr/local/msp430/
RUN wget -q -O device-libs.zip http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-support-files-1.210.zip && \
    unzip -q device-libs.zip && \
    mv /msp430-gcc-support-files/include/* /usr/local/msp430/include/


RUN wget -q -O mspdebug.tgz https://github.com/dlbeer/mspdebug/archive/v0.25.tar.gz &&\
    tar xzf mspdebug.tgz && \
    cd mspdebug-0.25 && \
    make && make install

RUN wget https://github.com/libusb/hidapi/archive/hidapi-0.9.0.tar.gz && \
    tar xzf hidapi-0.9.0.tar.gz && \
    cd hidapi-hidapi-0.9.0 && \
    ./bootstrap && \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ CFLAGS_LIBUSB=-fPIC ./configure && \
    make
RUN mkdir ti_msp_debug_stack && \
    cd ti_msp_debug_stack && \
    wget http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPDS/3_15_1_001/export/MSPDebugStack_OS_Package_3_15_1_1.zip && \
    unzip MSPDebugStack_OS_Package_3_15_1_1.zip && \
    cp /hidapi-hidapi-0.9.0/hidapi/hidapi.h ThirdParty/include/ && \
    cp /hidapi-hidapi-0.9.0/libusb/hid.o ThirdParty/lib64/hid-libusb.o && \
    make && \
    cp libmsp430.so /lib/x86_64-linux-gnu/
    

ENV PATH="/usr/local/msp430/bin:/usr/local/bin/:${PATH}"
