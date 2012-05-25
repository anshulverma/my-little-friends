#! /usr/bin/env bash

# $1 file

# Often, you want to split a huge XML file in a number of smaller ones
# to debug the Escenic Content Engine import.  This script will split
# the contents of the passed file into files with exactly one entry in
# each.
#
# The structure looks like this↓
# <item>
#   <articleid>...</articleid>
#   <articleid>...</articleid>
# </item>
first_level_element="item"
second_level_element="articleid"

i=1
cat $1 | \
    sed -n -e ":a" -e "$ s/\n//gp;N;b a" | \
    sed "s/<${second_level_element}>/\n<${second_level_element}>/g" | \

while read line; do 
    if [ $(echo $line | grep ^"<${second_level_element}>" | wc -l) -eq 0 ]; then
        continue
    fi

    file=${1}.${i}.xml

    cat > $file <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<${first_level_element}>
  $line
EOF
    if [ $(echo "$line" | grep "</${first_level_element}>" | wc -l) -eq 0 ]; then
        echo "</${first_level_element}>" >> $file
    fi

    i=$(( i + 1 ))
done

echo "$(basename $0):" ${1}.[0-9]*.xml "are ready"
