FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    meson \
    wget \
    unzip \
    build-essential \
    mspdebug

RUN wget -q -O toolchain.tar.bz2 http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-9.2.0.50_linux64.tar.bz2 && \
    tar xjf toolchain.tar.bz2 && \
    mv /msp430-gcc-9.2.0.50_linux64/ /usr/local/msp430/
RUN wget -q -O device-libs.zip http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_2_0_0/export/msp430-gcc-support-files-1.210.zip && \
    unzip -q device-libs.zip && \
    mv /msp430-gcc-support-files/include/* /usr/local/msp430/include/

ENV PATH="/usr/local/msp430/bin:${PATH}"
