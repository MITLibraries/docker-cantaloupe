FROM mostalive/ubuntu-14.04-oracle-jdk8

MAINTAINER Richard Rodgers <http://orcid.org/0000-0003-1412-5595>

ARG ctl_ver=2.1.1

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -y && apt-get install -y wget unzip

# Get and unpack Cantaloupe release archive
RUN wget https://github.com/medusa-project/cantaloupe/releases/download/v${ctl_ver}/Cantaloupe-${ctl_ver}.zip \
    && unzip Cantaloupe-${ctl_ver}.zip \
    && rm Cantaloupe-${ctl_ver}.zip

WORKDIR Cantaloupe-${ctl_ver}

# Configure image path to mapped volume and enable filesystem cache
RUN sed -e 's+home\/myself\/images+imageroot+' -e 's/#cache.server/cache.server/' < cantaloupe.properties.sample > ctl.props \
    && mv Cantaloupe-${ctl_ver}.jar Cantaloupe.jar

EXPOSE 8182
CMD ["java", "-Dcantaloupe.config=ctl.props", "-Xmx800m", "-jar", "Cantaloupe.jar"]
