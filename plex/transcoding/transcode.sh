#!/usr/bin/env bash

shopt -s nullglob
FILES=(/plex/originals/inbox/*.mkv)
shopt -u nullglob

if [ "${#FILES}" -ne 0 ]; then

  for SOURCE in "${FILES[@]}"; do

    # Random micro sleep to mitigate simultaneous startup race condition.
    sleep .${RANDOM:1:2}

    if [ -f "${SOURCE%.mkv}.inprogress" ] || [ ! -f "${SOURCE}" ]; then
      continue
    fi

    touch "${SOURCE%.mkv}.inprogress"

    cd $(mktemp -d -p /tmp/transcode)
    mkdir src
    cp "${SOURCE}" src/

    # Check size
    ORIG=$(wc -c "${SOURCE}" | cut -d' ' -f1)
    NEW=$(wc -c "src/${SOURCE##*/}" | cut -d' ' -f1)

    if [ "${NEW}" -ne "${ORIG}" ]; then
      echo "file mismatch!"
      rm "${SOURCE%.mkv}.inprogress"
      exit 1
    fi

    /usr/local/bin/classic-transcode "src/${SOURCE##*/}"

    ORIG=$(/usr/local/bin/ffprobe "src/${SOURCE##*/}" | awk '/Duration/ { print $2 }' | cut -d'.' -f1)
    NEW=$(/usr/local/bin/ffprobe "${SOURCE##*/}" | awk '/Duration/ { print $2 }' | cut -d'.' -f1)

    if [ "${NEW}" == "${ORIG}" ]; then
      cp "${SOURCE##*/}" /plex/rips/movies/
      mv "${SOURCE}" /plex/originals/movies/
      rm "${SOURCE%.mkv}.inprogress"
    fi

  done

fi

