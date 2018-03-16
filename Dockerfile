FROM openjdk:8-jdk-alpine

# install packages for alpine
RUN apk update  && \
    apk upgrade && \
    apk add --no-cache bash gcc make cmake git wget tar python3 xz shadow unzip

# Configure bash as the default shell
RUN chsh -s /bin/bash

# Get Kotlin Native from local zip with new zephyr_nucleo_f412zg platform target for zephyr
# Change back to loc 18 again once the target is merged into a future K/N release
COPY ./kotlin-native-linux-0.6.1-mod.zip ./kotlin-native-linux-0.6.1-mod.zip
RUN unzip kotlin-native-*.zip && \
    rm kotlin-native-*.zip

# Get Kotlin Native
#RUN wget https://github.com/JetBrains/kotlin-native/releases/download/v0.6.1/kotlin-native-linux-0.6.1.tar.gz && \
#    tar -xvzf kotlin-native-*.tar.gz && \
#    rm kotlin-native-*.tar.gz

# Set path for Kotlin Native, remove -mod with future K/N release
ENV PATH $PATH:/kotlin-native-linux-0.6.1-mod/bin

# Configure Zephyr SDK
RUN mkdir zephyr-sdk && cd zephyr-sdk && \
    wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9.2/zephyr-sdk-0.9.2-setup.run && \
    echo /opt/zephyr-sdk | sh zephyr-sdk-0.9.2-setup.run --nox11 && \
    export ZEPHYR_TOOLCHAIN_VARIANT=zephyr && \
    export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

# Configure Zephyr
RUN git clone https://github.com/zephyrproject-rtos/zephyr.git
