FROM java:8-jdk

MAINTAINER Richard Rodgers <http://orcid.org/0000-0003-1412-5595>

ARG ctl_ver=3.2

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -y && apt-get install -y wget unzip graphicsmagick imagemagick

# Get and unpack Cantaloupe release archive
RUN wget https://github.com/medusa-project/cantaloupe/releases/download/v${ctl_ver}/Cantaloupe-${ctl_ver}.zip \
    && unzip Cantaloupe-${ctl_ver}.zip \
    && rm Cantaloupe-${ctl_ver}.zip

WORKDIR Cantaloupe-${ctl_ver}


# Drop in config
COPY ctl.props ctl.props
COPY delegates.rb delegates.rb

# cleanup
RUN mv Cantaloupe-${ctl_ver}.war Cantaloupe.war

EXPOSE 8182
CMD ["java", "-Dcantaloupe.config=ctl.props", "-Xmx1800m", "-jar", "Cantaloupe.war"]
