#!/usr/bin/env bash

shopt -s nullglob
FILES=(/plex/originals/inbox/*.mkv)
shopt -u nullglob

if [ "${#FILES}" -ne 0 ]; then

  for SOURCE in "${FILES[@]}"; do

    # Random micro sleep to mitigate simultaneous startup race condition.
    sleep .${RANDOM:1:2}

    if [ -f "${SOURCE%.mkv}.inprogress" ]; then
      continue
    fi

    touch "${SOURCE%.mkv}.inprogress"

    cd $(mktemp -d -p /tmp/transcode)
    /usr/local/bin/classic-transcode "${SOURCE}"

    if [ "$?" -eq 0 ]; then
      mv "${SOURCE##*/}" /plex/rips/movies/
      mv "${SOURCE}" /plex/originals/movies/
      rm "${SOURCE%.mkv}.inprogress"
    else
      echo "something bad happened!"
      exit 1
    fi

  done

fi



