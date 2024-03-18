FROM ubuntu:20.04
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update
RUN apt install -y python3.10
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        wget \
        python3-pip \
        python3-setuptools \
        ca-certificates \
        build-essential \
        python3-dev \
        libsndfile1 \
        sox \
        && rm -rf /var/lib/apt/lists/*
        
RUN apt-get -y update && apt-get install -y wget nano git build-essential yasm pkg-config

# Compile and install ffmpeg from source
#RUN git clone https://github.com/FFmpeg/FFmpeg /root/ffmpeg && \
#    cd /root/ffmpeg && \
#    ./configure --enable-nonfree --disable-shared --extra-cflags=-I/usr/local/include && \
#    make -j8 && make install -j8



# Here we get all python packages.
# There's substantial overlap between scipy and numpy that we eliminate by
# linking them together. Likewise, pip leaves the install caches populated which uses
# a significant amount of space. These optimizations save a fair amount of space in the
# image, which reduces start up time.
RUN apt-get update
RUN apt-get install openssl
# RUN apt-get install sqlite3
RUN apt-get -y upgrade

COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -r requirements.txt && \
    rm -rf /root/.cache
RUN openssl version

#RUN pip3 install nvidia-docker2
#ENV DEBIAN_FRONTEND=noninteractive
#RUN apt install -y nvidia-driver-510

#RUN systemctl restart docker

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

RUN df -kh /dev/shm > /tmp/output

COPY src /opt/program
WORKDIR /opt/program
# ENTRYPOINT [""]
# CMD [ "python3", "serve.py" ]
