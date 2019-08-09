FROM debian:buster AS builder

ENV DEBIAN_FRONTEND="noninteractive"

# Enable deb-src repos so we can retrieve the packages used to build libopenjp2:
RUN sed -i -e '/^deb/p; s/^deb /deb-src /' /etc/apt/sources.list

RUN apt-get update -qqy && apt-get dist-upgrade -qqy && apt-get install -qqy quilt devscripts && apt-get build-dep -qy libopenjp2-tools

RUN adduser --system --group builder
RUN install -d -o builder -g builder /build

USER builder

WORKDIR /build

RUN apt-get source openjpeg2

WORKDIR /build/openjpeg2-2.3.0
ENV QUILT_PATCHES=debian/patches

# Add the patch from https://github.com/uclouvain/openjpeg/issues/1207
COPY handle_colorspace_conflicts.patch /build/

# Apply the patch to the local source directory
RUN quilt import /build/handle_colorspace_conflicts.patch
RUN quilt push -a -v

# Build all of the openjpeg2 packages
RUN debuild -uc -us

FROM debian:buster

ENV CANTALOUPE_VERSION=4.1.5

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick \
    ffmpeg unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean

# Install the patched openjpeg2 tools
COPY --from=builder /build/*.deb /tmp/
RUN dpkg -i /tmp/libopenjp2-*.deb /tmp/libopenjp2-tools-*.deb

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && unzip Cantaloupe-$CANTALOUPE_VERSION.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample -jar /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
