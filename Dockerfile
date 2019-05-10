# The default Cantaloupe version for our build
ARG CANTALOUPE_VERSION="4.1.1"

# Kakadu is optional; if there it should be your licensed kakadu software directory's name
ARG KAKADU_VERSION=

# COMMIT_REF should be 'latest' or a commit hash; it is a defense against a broken upstream
ARG COMMIT_REF="latest"

# It is not like there will ever be another JAI version, but...
ARG JAI_VERSION="1.1.3"
ARG JAI_IMAGEIO_VERSION="1.1"

# Transitive dependencies that Cantaloupe needs to build
ARG JAI_JAR="jai_codec-1.1.3.jar"
ARG JAI_CORE_JAR="jai_core-1.1.3.jar"
ARG JAI_IMAGEIO_JAR="jai_imageio-1.1.jar"

# Boo third party repos, but transitive deps are transitive deps :-(
ARG JAI_REPO="https://nexus.geomatys.com/repository/geotoolkit"

# We do a multi-stage build; the first stage builds the Cantaloupe code
FROM maven:3.6.0-jdk-11 AS MAVEN_TOOL_CHAIN

ARG CANTALOUPE_VERSION
ARG COMMIT_REF
ARG JAI_JAR
ARG JAI_CORE_JAR
ARG JAI_IMAGEIO_JAR
ARG JAI_REPO
ARG JAI_VERSION
ARG JAI_IMAGEIO_VERSION
ENV CANTALOUPE_VERSION="$CANTALOUPE_VERSION"
ENV COMMIT_REF="$COMMIT_REF"
ENV JAI_JAR="$JAI_JAR"
ENV JAI_CORE_JAR="$JAI_CORE_JAR"
ENV JAI_IMAGEIO_JAR="$JAI_IMAGEIO_JAR"
ENV JAI_REPO="$JAI_REPO"
ENV JAI_VERSION="$JAI_VERSION"
ENV JAI_IMAGEIO_VERSION="$JAI_IMAGEIO_VERSION"
ENV CANTALOUPE_RELEASES="https://github.com/cantaloupe-project/cantaloupe/releases/download"

WORKDIR /build/cantaloupe
RUN if [ "$CANTALOUPE_VERSION" = 'dev' ] ; then \
      git clone --quiet https://github.com/cantaloupe-project/cantaloupe.git . && \
      if [ "$COMMIT_REF" != 'latest' ] ; then \
        git checkout -b "$COMMIT_REF" "$COMMIT_REF" ; \
      fi && \
      # Janky, but third party repos and transitive dependences what can you do?
      curl "${JAI_REPO}/javax/media/jai_codec/${JAI_VERSION}/${JAI_JAR}" > "/tmp/${JAI_JAR}" && \
      curl "${JAI_REPO}/javax/media/jai_core/${JAI_VERSION}/${JAI_CORE_JAR}" > "/tmp/${JAI_CORE_JAR}" && \
      curl "${JAI_REPO}/javax/media/jai_imageio/${JAI_IMAGEIO_VERSION}/${JAI_IMAGEIO_JAR}" > "/tmp/${JAI_IMAGEIO_JAR}" && \
      mvn -q install:install-file -Dfile="/tmp/${JAI_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_codec" -Dversion="$JAI_VERSION" -Dpackaging="jar" && \
      mvn -q install:install-file -Dfile="/tmp/${JAI_CORE_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_core" -Dversion="$JAI_VERSION" -Dpackaging="jar" && \
      mvn -q install:install-file -Dfile="/tmp/${JAI_IMAGEIO_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_imageio" -Dversion="$JAI_IMAGEIO_VERSION" -Dpackaging="jar" && \
      # end jank
      mvn -DskipTests=true -q clean package && \
      mv target/cantaloupe-?.?-SNAPSHOT.zip "/build/Cantaloupe-${CANTALOUPE_VERSION}.zip" ; \
    else \
      curl -o "../Cantaloupe-${CANTALOUPE_VERSION}.zip" -s -L \
        "${CANTALOUPE_RELEASES}/v${CANTALOUPE_VERSION}/Cantaloupe-${CANTALOUPE_VERSION}.zip" ; \
    fi

# The second stage of our multi-stage build builds the kakadu libraries and binaries
FROM ubuntu:18.10 AS KAKADU_TOOL_CHAIN

ARG KAKADU_VERSION
ENV KAKADU_VERSION="$KAKADU_VERSION"
ENV BUILD_ARCH=Linux-x86-64-gcc

COPY kakadu /build/kakadu/
WORKDIR /build/kakadu/"$KAKADU_VERSION"/make
RUN if [ ! -z "$KAKADU_VERSION" ]; then \
      apt-get update -qq ; \
      DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
        gcc=4:8.3.0-1ubuntu1.1 \
        make=4.2.1-1.2 \
        libtiff-tools=4.0.9-6ubuntu0.2 \
        libtiff5=4.0.9-6ubuntu0.2 \
        libtiff5-dev=4.0.9-6ubuntu0.2 \
        build-essential=12.5ubuntu2 ; \
      make -f Makefile-$BUILD_ARCH ; \
      mkdir /build/kakadu/lib ; \
      mkdir /build/kakadu/bin ; \
      cp ../lib/$BUILD_ARCH/*.so /build/kakadu/lib ; \
      cp ../bin/$BUILD_ARCH/kdu_compress /build/kakadu/bin ; \
      cp ../bin/$BUILD_ARCH/kdu_expand /build/kakadu/bin ; \
      cp ../bin/$BUILD_ARCH/kdu_jp2info /build/kakadu/bin ; \
    else \
      mkdir -p /build/kakadu/lib ; \
      mkdir -p /build/kakadu/bin ; \
      touch /build/kakadu/lib/placeholder.so ; \
      touch /build/kakadu/bin/kdu_placeholder ; \
    fi

# The third and final stage of our multi-stage build pulls all the pieces together
FROM ubuntu:18.10
ARG CANTALOUPE_VERSION
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION
ENV CONFIG_FILE="/etc/cantaloupe.properties"

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
#  Removing /var/lib/apt/lists/* prevents using `apt` unless you do `apt update` first
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -qq --no-install-recommends \
    libtiff-tools=4.0.9-6ubuntu0.2 \
    libtiff5=4.0.9-6ubuntu0.2 \
    libtiff5-dev=4.0.9-6ubuntu0.2 \
    libopenjp2-tools=2.3.0-1 \
    openjdk-11-jre-headless=11.0.2+9-3ubuntu1~18.10.3  \
    wget=1.19.5-1ubuntu1.1 \
    unzip=6.0-21ubuntu1 \
    graphicsmagick=1.3.30+hg15796-1 \
    curl=7.61.0-1ubuntu2.3 \
    imagemagick=8:6.9.10.8+dfsg-1ubuntu2 \
    ffmpeg=7:4.0.4-0ubuntu1 \
    python=2.7.15-3 \
    < /dev/null > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# Run Cantaloupe non-privileged
RUN adduser --system cantaloupe

# Copy work product from the Cantaloupe build into our image
WORKDIR /tmp
COPY --from=MAVEN_TOOL_CHAIN "/build/Cantaloupe-$CANTALOUPE_VERSION.zip" "/tmp/Cantaloupe-$CANTALOUPE_VERSION.zip"

WORKDIR /usr/local
RUN unzip -qq "/tmp/Cantaloupe-$CANTALOUPE_VERSION.zip" ; \
    ln -s cantaloupe-?.* cantaloupe ; \
    rm -rf "/tmp/Cantaloupe-$CANTALOUPE_VERSION" ; \
    rm "/tmp/Cantaloupe-$CANTALOUPE_VERSION.zip" ; \
    rm -rf "/usr/local/cantaloupe-$CANTALOUPE_VERSION/deps"

# Put our Kakadu libs in a directory that's in the LD_LIBRARY_PATH
WORKDIR /usr/lib/jni
COPY --from=KAKADU_TOOL_CHAIN /build/kakadu/lib/* /usr/lib/jni/

# Put our Kakadu bins in the local bin directory
WORKDIR /usr/local/bin
COPY --from=KAKADU_TOOL_CHAIN /build/kakadu/bin/* /usr/local/bin/

# Cantaloupe is aware of '/usr/lib/jni' but the system is not
ENV LD_LIBRARY_PATH="/usr/lib/jni:${LD_LIBRARY_PATH}"

# Clean up the placeholder files if we built without kakadu
RUN if [ -z "$KAKADU_VERSION" ]; then \
      rm -rf /build/kakadu/lib/placeholder.so ; \
      rm -rf /build/kakadu/bin/kdu_placeholder ; \
    fi

# Set up our config file (and config file override) components
COPY docker-entrypoint.sh /usr/local/bin/
COPY "configs/cantaloupe.properties.tmpl-$CANTALOUPE_VERSION" /etc/cantaloupe.properties.tmpl
COPY "configs/cantaloupe.properties.default-$CANTALOUPE_VERSION" /etc/cantaloupe.properties.default
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe ; \
    touch "$CONFIG_FILE" ; \
    chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe "$CONFIG_FILE" /usr/local/bin/docker-entrypoint.sh

# Wrap things up with the entrypoint and command that the container runs
USER cantaloupe
WORKDIR /home/cantaloupe
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "java -Dcantaloupe.config=$CONFIG_FILE -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-*.war"]
