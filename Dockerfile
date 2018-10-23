FROM openjdk:10-slim

ENV CANTALOUPE_VERSION=4.0.1
EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -y && apt-get install -y wget unzip graphicsmagick curl

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

# KAKADU Install
RUN mkdir -p /tools && \
    cd /tools && \
    wget -O kakadu.zip http://kakadusoftware.com/wp-content/uploads/2014/06/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip && \
    unzip kakadu.zip -d kakadu && \
    rm -f kakadu.zip

ENV PATH /tools/kakadu/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827:${PATH}
ENV LD_LIBRARY_PATH /tools/kakadu/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827:${LD_LIBRARY_PATH}

# Get and unpack Cantaloupe release archive
RUN curl -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && mkdir -p /usr/local/ \
 && cd /usr/local \
 && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
 && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
 && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

COPY cantaloupe.properties /etc/cantaloupe.properties
RUN mkdir -p /var/log/cantaloupe \
 && mkdir -p /var/cache/cantaloupe \
 && chown -R cantaloupe /var/log/cantaloupe \
 && chown -R cantaloupe /var/cache/cantaloupe \
 && chown cantaloupe /etc/cantaloupe.properties

USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
