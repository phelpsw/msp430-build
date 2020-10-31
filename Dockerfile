FROM ubuntu:20.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update \
    # Basic tools
    && apt-get -y install wget unzip git \
    # Build system
    && apt-get -y install build-essential meson \
    # mspdebug dependencies
    && apt-get -y install libusb-dev libreadline-dev \
    # msp430-gdb dependency
    && apt-get -y install libncursesw5 \
    # hidapi dependencies
    && apt-get -y install libudev1 libudev-dev libusb-1.0-0-dev  \
    # TI MSP debug stack tilib dependency
    && apt-get -y install pkg-config libboost1.67 \
    # Unity and CMock
    && apt-get -y install ruby \
    # Valgrind for general debugging
    && apt-get -y install valgrind \
    # gcov and lcov for code coverage
    && apt-get -y install gcovr lcov \
    # Create a non-root user to use if preferred
    # see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -a -G dialout $USERNAME \
    # Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# TI MSP430 gcc toolchain
RUN wget -q -O toolchain.tar.bz2 http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-9.2.0.50_linux64.tar.bz2 && \
    tar xjf toolchain.tar.bz2 && \
    mv /msp430-gcc-9.2.0.50_linux64/ /usr/local/msp430/
# TI MSP430 device headers
RUN wget -q -O device-libs.zip http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-support-files-1.210.zip && \
    unzip -q device-libs.zip && \
    mv /msp430-gcc-support-files/include/* /usr/local/msp430/include/

# Recent version of mspdebug
RUN wget -q -O mspdebug.tgz https://github.com/dlbeer/mspdebug/archive/v0.25.tar.gz &&\
    tar xzf mspdebug.tgz && \
    cd mspdebug-0.25 && \
    make && make install

# libhidapi required by the TI debug stack
RUN wget https://github.com/libusb/hidapi/archive/hidapi-0.9.0.tar.gz && \
    tar xzf hidapi-0.9.0.tar.gz && \
    cd hidapi-hidapi-0.9.0 && \
    ./bootstrap && \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ CFLAGS_LIBUSB=-fPIC ./configure && \
    make
# TI MSP debug stack needed by mspdebug 'tilib' driver
RUN mkdir ti_msp_debug_stack && \
    cd ti_msp_debug_stack && \
    wget http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPDS/3_15_1_001/export/MSPDebugStack_OS_Package_3_15_1_1.zip && \
    unzip MSPDebugStack_OS_Package_3_15_1_1.zip && \
    cp /hidapi-hidapi-0.9.0/hidapi/hidapi.h ThirdParty/include/ && \
    cp /hidapi-hidapi-0.9.0/libusb/hid.o ThirdParty/lib64/hid-libusb.o && \
    make && \
    cp libmsp430.so /lib/x86_64-linux-gnu/

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

ENV PATH="/usr/local/msp430/bin:/usr/local/bin/:${PATH}"
