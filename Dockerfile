FROM debian:jessie

# Add non-free for libfaac
RUN sed -i "s/jessie main/jessie main non-free/" /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  git-core \
  build-essential \
  ruby \
  curl \
  exiv2 \
  libexiv2-dev \
  autoconf \
  automake \
  build-essential \
  libass-dev \
  libfreetype6-dev \
  libtheora-dev \
  libtool \
  libvorbis-dev \
  pkg-config \
  texi2html \
  zlib1g-dev \
  wget \
  yasm \
  libx264-dev \
  libfaac-dev \
  mediainfo \
  libmp3lame-dev \
  libasound2-dev \
  python \
  vim

RUN mkdir ~/ffmpeg_sources

RUN cd ~/ffmpeg_sources && \
  wget https://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.gz && \
  tar xvf nasm-2.14.tar.gz && \
  cd nasm* && \
  ./configure && \
  make && \
  make install && \
  nasm --version

RUN cd ~/ffmpeg_sources && \
  wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
  tar xjvf last_x264.tar.bz2 && \
  cd x264-snapshot* && \
  PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static && \
  PATH="$HOME/bin:$PATH" make && \
  make install && \
  make distclean

RUN cd ~/ffmpeg_sources && \
  wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
  tar xzvf fdk-aac.tar.gz && \
  cd mstorsjo-fdk-aac* && \
  autoreconf -fiv && \
  ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
  make && \
  make install && \
  make distclean

RUN cd ~/ffmpeg_sources && \
  wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
  tar xjvf ffmpeg-snapshot.tar.bz2 && \
  cd ffmpeg && \
  PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
      --prefix="$HOME/ffmpeg_build" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I$HOME/ffmpeg_build/include" \
      --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
      --bindir="$HOME/bin" \
      --enable-gpl \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libmp3lame \
      --enable-libx264 \
      --enable-nonfree && \
  PATH="$HOME/bin:$PATH" make && \
  make install && \
  make distclean && \
  hash -r

# Add /root/bin to path for ffmpeg
ENV PATH /root/bin:$PATH

# Set the entry point
ENTRYPOINT ["/init"]

# Install services
COPY services /etc/services.d

# Install init.sh as init script
COPY init.sh /etc/cont-init.d/

COPY runffmpeg.py /root/

# Download and extract s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

