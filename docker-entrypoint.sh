#!/usr/bin/env bash

PROPERTIES=/etc/cantaloupe.properties
PROPERTIES_TMPL=/etc/cantaloupe.properties.tmpl
PYTHON=$(which python)
read -d '' SCRIPT <<- EOT
import os,string;
fp=open('$PROPERTIES_TMPL');
t=string.Template(fp.read());
print(t.safe_substitute(os.environ))
EOT

$PYTHON -c "$SCRIPT" >> $PROPERTIES

exec "$@"
