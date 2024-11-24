#!/bin/bash

cd /mnt/nfs_mini/Music
ARTISTS=$(find . -maxdepth 1 -type d | grep -Ev '^.$')
IFS=$'\n'
for ARTIST in $ARTISTS; do
  echo -e "Process ${ARTIST}"
  cd "${ARTIST}"

    for ALBUM in $(find . -maxdepth 1 -type d | grep -Ev '^.$'); do
      if [[ ! -f "${ALBUM}.zip" ]]; then
        zip -r "${ALBUM}.zip" "${ALBUM}"
      else
        echo "$ALBUM has already been zipped"
      fi
    done
  
  cd ..
done
