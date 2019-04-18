#!/bin/bash

## USAGE DETAILS
## ./convert-default.sh cantaloupe.properties.tmpl-dev cantaloupe.properties.sample
## $1 = Template file with ENV mapping
## $2 = File to write to, ideally this is a new sample config supplied from Cantaloupe
sed "s/\$CANTALOUPE/CANTALOUPE/g" $1 | sed '/^$/d' | sed '/^#/d' | sed "s/\ =\ /|/g" > mapper_output
for x in $(cat mapper_output);
do
  SEARCHVAR=$(echo $x | cut -d '|' -f1)
  REPLACEVAR=$(echo $x | cut -d '|' -f2)
  sed -i "s/$SEARCHVAR/$REPLACEVAR/g" $2
done
rm mapper_output
