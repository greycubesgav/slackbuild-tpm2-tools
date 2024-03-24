FROM vbatts/slackware:15.0

USER root
ENV USER=root


RUN echo y | slackpkg update

RUN echo y | slackpkg install lzlib

RUN echo y | slackpkg install \
      autoconf \
      autoconf-archive \
      automake \
      binutils \
      kernel-headers \
      pkg-tools \
      glibc \
      automake \
      autoconf \
      m4 \
      gcc \
      g++ \
      meson \
      ninja \
      ar \
      flex \
      pkg-config \
      cmake \
      libarchive \
      lz4 \
      libxml2 \
      nghttp2 \
      brotli \
      cyrus-sasl \
      jansson \
      elfutils \
      guile \
      gc \
      cryptsetup \
      curl \
      python3 \
      zlib \
      socat \
      linuxdoc-tools \
      keyutils \
      openssl \
      libxslt \
      openldap \
      libnsl \
      lvm2 \
      eudev \
      json-c  \
      make \
      libffi \
      libidn2 \
      libssh2 \
      ca-certificates

RUN echo y | slackpkg install \
      libgcrypt \
      libgpg-error \
      dcron \
      udisks2

RUN echo y | slackpkg install \
      openssh

# Set the SlackBuild tag
ENV TAG='_GG'
ENV BUILD='GG'

# Cryptsetup build
WORKDIR /root
RUN echo y | slackpkg install lvm2 \
 popt \
 pkg-config \
 json-c \
 libssh2 \
 libssh \
 argon2 \
 flex \
 libgpg-error \
 libgcrypt

RUN mkdir cryptsetup
WORKDIR /root/cryptsetup
RUN wget --no-check-certificate 'https://mirrors.slackware.com/slackware/slackware64-current/source/a/cryptsetup/cryptsetup-2.7.1.tar.xz'
RUN wget --no-check-certificate 'https://mirrors.slackware.com/slackware/slackware64-current/source/a/cryptsetup/cryptsetup.SlackBuild'
RUN chmod +x cryptsetup.SlackBuild
RUN ./cryptsetup.SlackBuild
RUN installpkg /tmp/cryptsetup-2.7.1-x86_64-GG.txz

# Build luksmeta from custom slackware-build
# Install for clevis build
RUN echo y | slackpkg install infozip
RUN mkdir /root/tpm2-tss
WORKDIR /root/tpm2-tss
RUN wget --no-check-certificate 'https://github.com/greycubesgav/slackbuild-tpm2-tss/archive/refs/heads/main.zip' -O tpm2-tss-build.zip
RUN unzip tpm2-tss-build.zip
WORKDIR /root/tpm2-tss/slackbuild-tpm2-tss-main
RUN wget --no-check-certificate $(sed -n 's/DOWNLOAD="\(.*\)"/\1/p' *.info)
RUN ./tpm2-tss.SlackBuild
RUN installpkg /tmp/tpm2-tss-4.0.1-x86_64-GG_GG.tgz

# Make and Install tpm2-tools for clevis
COPY src/tpm2-tools-5.6.tar.gz /root/tpm2-tools/
COPY tpm2-tools.SlackBuild /root/tpm2-tools/
COPY slack-desc /root/tpm2-tools/
COPY tpm2-tools.info /root/tpm2-tools/
WORKDIR /root/tpm2-tools/
RUN ./tpm2-tools.SlackBuild
RUN installpkg "/tmp/tpm2-tools-5.6-x86_64-$BUILD$TAG.tgz"

#RUN wget --no-check-certificate 'https://github.com/tpm2-software/tpm2-tools/releases/download/5.6/tpm2-tools-5.6.tar.gz'
#RUN tar zxf tpm2-tools-5.6.tar.gz
#WORKDIR /root/tpm2-tools-5.6
#RUN export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:${PKG_CONFIG_PATH}" && ./configure --prefix=/usr
#RUN make && make install

CMD ["/bin/bash","-l"]
