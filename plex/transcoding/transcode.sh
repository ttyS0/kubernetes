#!/usr/bin/env bash

shopt -s nullglob
FILES=(/plex/originals/inbox/*.mkv)
shopt -u nullglob

if [ "${#FILES}" -ne 0 ]; then

  for SOURCE in "${FILES[@]}"; do

    # Random micro sleep to mitigate simultaneous startup race condition.
    sleep .${RANDOM:1:2}

    # Find a file that isn't already in progress
    if [ -f "${SOURCE%.mkv}.inprogress" ] || [ ! -f "${SOURCE}" ]; then
      continue
    fi

    # Claim the file
    touch "${SOURCE%.mkv}.inprogress"

    # Setup workspace on local storage
    cd $(mktemp -d -p /tmp/transcode)
    mkdir src
    cp "${SOURCE}" src/

    # Verify the copied source file
    ORIG=$(md5sum "${SOURCE}" | cut -d' ' -f1)
    NEW=$(md5sum "src/${SOURCE##*/}" | cut -d' ' -f1)

    if [ "${NEW}" != "${ORIG}" ]; then
      echo "file mismatch!"
      rm "${SOURCE%.mkv}.inprogress"
      exit 1
    fi

    # Transcode!
    /usr/local/bin/classic-transcode "src/${SOURCE##*/}"

    # The exit code can't be trusted, so do a sanity check based on duration
    ORIG=$(/usr/local/bin/ffprobe "src/${SOURCE##*/}" 2>&1 | awk '/Duration/ { print $2 }' | cut -d'.' -f1)
    NEW=$(/usr/local/bin/ffprobe "${SOURCE##*/}" 2>&1 | awk '/Duration/ { print $2 }' | cut -d'.' -f1)

    # If the duration checks out, copy the transcode to Plex, and clean up
    if [ "${NEW}" == "${ORIG}" ]; then
      cp "${SOURCE##*/}" /plex/rips/movies/
      mv "${SOURCE}" /plex/originals/movies/
      rm "${SOURCE%.mkv}.inprogress"
      rm -rf /tmp/transcode/tmp.*
    else
      echo "something went wrong!"
      exit 1
    fi

  done

fi

