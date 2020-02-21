FROM debian:buster

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick libopenjp2-tools ffmpeg gettext unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

ARG CANTALOUPE_VERSION=4.1.2
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mkdir -p /usr/local/ \
    && cd /usr/local \
    && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
    && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp /usr/local/cantaloupe/deps/Linux-x86-64/lib/* /usr/lib/ \
    && cp /usr/local/cantaloupe/deps/Linux-x86-64/bin/* /usr/bin/
COPY cantaloupe.properties.sample /etc/cantaloupe.properties


USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe.properties -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
