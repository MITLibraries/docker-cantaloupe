FROM openjdk:11-slim
#ENV IMAGEMAGICK_VERSION=7.0.8-14

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
   apt-get install -qy --no-install-recommends graphicsmagick curl imagemagick libopenjp2-tools ffmpeg gettext unzip && \
   apt-get -qqy autoremove && apt-get -qqy autoclean

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

#ImageMagick 7 install - re-evaluate once officially deprecated
#RUN cd /tools && \
#    wget http://imagemagick.org/download/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    tar -xf ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    cd ImageMagick-$IMAGEMAGICK_VERSION && \
#    ./configure --prefix /usr/local && \
#    make && \
#    make install && \
#    cd .. && \
#    ldconfig /usr/local/lib && \
#    rm -rf  ImageMagick*

ARG CANTALOUPE_VERSION=4.1.1
ENV CANTALOUPE_VERSION=$CANTALOUPE_VERSION

# Get and unpack Cantaloupe release archive
RUN curl -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && mkdir -p /usr/local/ \
 && cd /usr/local \
 && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
 && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
 && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

COPY entrypoint.sh /usr/local/bin/
COPY cantaloupe.properties.tmpl /etc/cantaloupe.properties.tmpl
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
 && touch /etc/cantaloupe.properties \
 && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    /etc/cantaloupe.properties /usr/local/bin/entrypoint.sh \
 && cp /usr/local/cantaloupe/deps/Linux-x86-64/lib/* /usr/lib/ \
 && cp /usr/local/cantaloupe/deps/Linux-x86-64/bin/* /usr/bin/


USER cantaloupe
ENTRYPOINT ["entrypoint.sh"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe.properties -Xmx4g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
