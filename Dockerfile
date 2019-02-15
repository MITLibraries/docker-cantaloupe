ARG CANTALOUPE_VERSION=4.0.3
# LATEST_SAFE_COMMIT should be 'latest' or a commit hash; it is a defense against a broken upstream
ARG COMMIT_REF=latest
FROM maven:3.6.0-jdk-11 AS MAVEN_TOOL_CHAIN
ARG CANTALOUPE_VERSION
ARG COMMIT_REF
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION
ENV COMMIT_REF=$COMMIT_REF
RUN mkdir -p /build && \
    cd /build && \
    if [ "$CANTALOUPE_VERSION" = 'latest' ] ; then \
      git clone https://github.com/medusa-project/cantaloupe.git && \
      cd cantaloupe && \
      if [ "$COMMIT_REF" != 'latest' ] ; then \
        git checkout -b "$COMMIT_REF" "$COMMIT_REF" ; \
      fi && \
      mvn -DskipTests=true -q clean package && \
      mv target/cantaloupe-?.?-SNAPSHOT.zip "/build/Cantaloupe-${CANTALOUPE_VERSION}.zip" ; \
    else \
      curl -s -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip; \
    fi

FROM ubuntu:18.04
ARG CANTALOUPE_VERSION
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
#  Removing /var/lib/apt/lists/* prevents using `apt` unless you do `apt update` first
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget unzip graphicsmagick curl imagemagick libopenjp2-tools \
      ffmpeg python openjdk-11-jdk-headless && \
    rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

COPY --from=MAVEN_TOOL_CHAIN /build/Cantaloupe-$CANTALOUPE_VERSION.zip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

# Get and unpack Cantaloupe release archive
RUN cd /usr/local \
 && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
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