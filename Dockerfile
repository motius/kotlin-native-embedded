FROM fedora:latest

RUN dnf group install "Development Tools" "C Development Tools and Libraries" -y
RUN dnf install gradle \
                cmake \
                ncurses-compat-libs \
                ninja-build \
                gperf \
                dfu-util \
                dtc \
                python3-ply \
                python3-yaml \
                python3-pykwalify \
                glibc-devel.i686 \
                libstdc++-devel.i686 \
                wget \
                xz \
            -y

WORKDIR root

# Get Kotlin Native from local zip with new nucleo_f4112zg platform target for zephyr
# Should be changed to the lower implementation again once the target is merged into a future Kotlin/Native release
COPY ./dist.zip ./dist.zip
RUN unzip dist.zip && \
    rm -rf dist.zip
ENV PATH /root/dist/bin:$PATH

# Run this to fetch dependencies "This is a one-time action performed only on the first run of the compiler."
COPY ./start.kt ./start.kt
RUN konanc start.kt -target zephyr_stm32f4_disco

# Get Kotlin Native
#RUN wget https://github.com/JetBrains/kotlin-native/releases/download/v0.6.1/kotlin-native-linux-0.6.1.tar.gz && \
#    tar -xvzf kotlin-native-*.tar.gz && \
#    rm kotlin-native-*.tar.gz

# Configure Zephyr SDK
RUN mkdir zephyr-sdk && cd zephyr-sdk && \
    wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9.2/zephyr-sdk-0.9.2-setup.run && \
    echo /opt/zephyr-sdk | sh zephyr-sdk-0.9.2-setup.run --nox11 && \
    export ZEPHYR_TOOLCHAIN_VARIANT=zephyr && \
    export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

# Configure Zephyr
RUN git clone https://github.com/zephyrproject-rtos/zephyr.git
WORKDIR zephyr
RUN pip3 install --user -r scripts/requirements.txt
WORKDIR root
