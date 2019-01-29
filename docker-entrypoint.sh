#!/usr/bin/env bash

# Define locations of our container's property values
PROPERTIES=/etc/cantaloupe.properties
PROPERTIES_TMPL=/etc/cantaloupe.properties.tmpl
PROPERTIES_DEFAULT=/etc/cantaloupe.properties.default

# Find the python application on our system
PYTHON=$(which python)

# Create properties file from defaults and environment
read -d '' SCRIPT <<- EOT
import os,string,ConfigParser,StringIO;
template=string.Template(open('$PROPERTIES_TMPL').read());
config = StringIO.StringIO()
config.write('[cantaloupe]\n')
config.write(open('$PROPERTIES_DEFAULT').read())
config.seek(0, os.SEEK_SET)
config_parser = ConfigParser.ConfigParser()
config_parser.optionxform = str
config_parser.readfp(config)
properties = dict(config_parser.items('cantaloupe'))
properties.update(os.environ)
print(template.safe_substitute(properties))
EOT

# Write our merged properties file to /etc directory
$PYTHON -c "$SCRIPT" >> $PROPERTIES

# Replaces parent process so signals are processed correctly
exec "$@"
