FROM ubuntu:latest as build

RUN apt update
RUN apt install -y build-essential cargo cmake git glslang-tools google-mock libavcodec-extra \
    libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libcurl4-openssl-dev \
    libfreetype6-dev libglew-dev libnotify-dev libogg-dev libopus-dev libopusfile-dev libpng-dev \
    libsdl2-dev libsqlite3-dev libssl-dev libvulkan-dev libwavpack-dev libx264-dev python3 rustc spirv-tools


WORKDIR /opt
RUN git clone --recurse-submodules https://github.com/teeworlds/teeworlds.git teeworlds
WORKDIR /opt/teeworlds
ENV TEEWORLDS_TAG 0.7.5
RUN git checkout tags/$TEEWORLDS_TAG
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR /opt/teeworlds/build
RUN cmake .. -DCLIENT=OFF
RUN make

WORKDIR /opt
RUN git clone --recurse-submodules https://github.com/ddnet/ddnet.git
WORKDIR /opt/ddnet
ENV DDNET_TAG 18.8
RUN git checkout tags/$DDNET_TAG
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR /opt/ddnet/build
RUN cmake .. -DCLIENT=OFF
RUN make

WORKDIR /opt
RUN git clone https://github.com/Jupeyy/teeworlds-fng2-mod.git fng
WORKDIR /opt/fng
RUN git checkout master
ENV FNG_COMMIT_HASH 07ac6046c37eba552d5d0b59bcc7bf35904b3e4f
RUN git checkout $FNG_COMMIT_HASH
RUN mkdir build
WORKDIR /opt/fng/build
RUN cmake .. -DCLIENT=OFF
RUN make

WORKDIR /opt
RUN git clone https://github.com/igholami/zcatch.git zcatch
WORKDIR /opt/zcatch
ENV ZCATCH_TAG v0.2.0
RUN git fetch && git checkout tags/$ZCATCH_TAG
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR /opt/zcatch/build
RUN cmake .. -DCLIENT=OFF
RUN make

FROM ubuntu:latest

RUN apt update
RUN apt install -y libcurl4-openssl-dev libsqlite3-dev

WORKDIR /opt

RUN mkdir configs

RUN mkdir zcatch
COPY --from=build /opt/zcatch/build/zcatch_srv /opt/zcatch/zcatch_srv
COPY --from=build /opt/zcatch/build/data /opt/zcatch/data
ADD configs/zcatch.cfg /opt/zcatch/zcatch.cfg

RUN mkdir fng2
COPY --from=build /opt/fng/build/fng2_srv /opt/fng2/fng2_srv
COPY --from=build /opt/fng/build/maps /opt/fng2/maps
ADD configs/fng2.cfg /opt/fng2/fng2.cfg

RUN mkdir teeworlds
COPY --from=build /opt/teeworlds/build/teeworlds_srv /opt/teeworlds/teeworlds_srv
COPY --from=build /opt/teeworlds/build/data /opt/teeworlds/data
ADD configs/ctf.cfg /opt/teeworlds/ctf.cfg

RUN mkdir ddnet
COPY --from=build /opt/ddnet/build/DDNet-Server /opt/ddnet/ddnet_srv
COPY --from=build /opt/ddnet/build/data /opt/ddnet/data
ADD configs/ddnet.cfg /opt/ddnet/ddnet.cfg
ADD maps/ddnet/* /opt/ddnet/data/maps7/
ADD maps/ddnet/* /opt/ddnet/data/maps/

ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]