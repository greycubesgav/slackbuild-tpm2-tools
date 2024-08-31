FROM greycubesgav/slackware-docker-base:latest AS builder

# Set our prepended build artifact tag and build dir
ENV TAG='_GG'

#--------------------------------------------------------------
# Cryptsetup Install
#--------------------------------------------------------------
# We need a version of cryptsetup to builf tpm2-tss against
# Here we pull a specific version from the official repository
# which matches the version shipped with Unraid version 6.12.11
ARG CRYPTSETUP_VERSION=cryptsetup-2.6.1-x86_64-1_GG.txz
WORKDIR /root/cryptsetup/
RUN wget --no-check-certificate "https://github.com/greycubesgav/slackbuild-cryptsetup/releases/download/main/${CRYPTSETUP_VERSION}"
RUN installpkg ./cryptsetup-*.txz

#--------------------------------------------------------------
# tpm2-tss Install
#--------------------------------------------------------------
# We need a version of tpm2-tss to build tpm2-tools against
ARG TPM2TSS_VERSION=tpm2-tss-4.0.1-x86_64-1_GG.tgz
WORKDIR /root/tpm2-tss/
RUN wget --no-check-certificate "https://github.com/greycubesgav/slackbuild-tpm2-tss/releases/download/main/${TPM2TSS_VERSION}"
RUN installpkg ./tpm2-tss-*.tgz

#--------------------------------------------------------------
# Build Slackware Package
#--------------------------------------------------------------
# Copy over the build files
COPY LICENSE *.info *.SlackBuild README slack-desc /root/build/

# Grab the source and check the md5
WORKDIR /root/build/
RUN wget --no-check-certificate $(sed -n 's/DOWNLOAD="\(.*\)"/\1/p' *.info)
RUN export pkgname=$(grep 'DOWNLOAD=' *.info| sed 's|.*/||;s|"||g') \
&& export pkgmd5sum=$(sed -n 's/MD5SUM="\(.*\)"/\1/p' *.info) \
&& echo "$pkgmd5sum  $pkgname" > "${pkgname}.md5" \
&& md5sum -c "${pkgname}.md5"

# Build the package
RUN ./*.SlackBuild

#ENTRYPOINT [ "bash" ]

# Create a clean image with only the artifact
FROM scratch AS artifact
COPY --from=builder /tmp/tpm2-tss*.tgz .
