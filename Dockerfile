ARG CANTALOUPE_VERSION=4.0.3
# LATEST_SAFE_COMMIT should be 'latest' or a commit hash; it is a defense against a broken upstream
ARG COMMIT_REF=latest
FROM maven:3.6.0-jdk-11 AS MAVEN_TOOL_CHAIN
ARG CANTALOUPE_VERSION
ARG COMMIT_REF
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION
ENV COMMIT_REF=$COMMIT_REF
WORKDIR /build/cantaloupe
RUN if [ "$CANTALOUPE_VERSION" = 'dev' ] ; then \
      git clone --quiet https://github.com/medusa-project/cantaloupe.git . && \
      if [ "$COMMIT_REF" != 'latest' ] ; then \
        git checkout -b "$COMMIT_REF" "$COMMIT_REF" ; \
      fi && \
      mvn -DskipTests=true -q clean package && \
      mv target/cantaloupe-?.?-SNAPSHOT.zip "/build/Cantaloupe-${CANTALOUPE_VERSION}.zip" ; \
    else \
      curl -o ../Cantaloupe-$CANTALOUPE_VERSION.zip -s -L https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip; \
    fi

FROM ubuntu:18.04
ARG CANTALOUPE_VERSION
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
#  Removing /var/lib/apt/lists/* prevents using `apt` unless you do `apt update` first
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -qq --no-install-recommends \
    libopenjp2-tools=2.3.0-1 \
    openjdk-11-jre-headless=10.0.2+13-1ubuntu0.18.04.4 \
    wget=1.19.4-1ubuntu2.1 \
    unzip=6.0-21ubuntu1 \
    graphicsmagick=1.3.28-2 \
    curl=7.58.0-2ubuntu3.6 \
    imagemagick=8:6.9.7.4+dfsg-16ubuntu6.4 \
    ffmpeg=7:3.4.4-0ubuntu0.18.04.1 \
    python=2.7.15~rc1-1 \
    < /dev/null > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

COPY --from=MAVEN_TOOL_CHAIN /build/Cantaloupe-$CANTALOUPE_VERSION.zip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

# Get and unpack Cantaloupe release archive

WORKDIR /usr/local

RUN unzip -qq /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && ln -s cantaloupe-?.* cantaloupe \
 && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
 && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && rm -rf /usr/local/cantaloupe-$CANTALOUPE_VERSION/deps

COPY docker-entrypoint.sh /usr/local/bin/
COPY configs/cantaloupe.properties.tmpl-$CANTALOUPE_VERSION /etc/cantaloupe.properties.tmpl
COPY configs/cantaloupe.properties.default-$CANTALOUPE_VERSION /etc/cantaloupe.properties.default
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
 && touch /etc/cantaloupe.properties \
 && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    /etc/cantaloupe.properties /usr/local/bin/docker-entrypoint.sh

USER cantaloupe
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-*.war"]
