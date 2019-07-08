#!/usr/bin/env bash

envsubst < /etc/cantaloupe.properties.tmpl > /etc/cantaloupe.properties

exec "$@"
