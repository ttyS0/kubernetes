#!/usr/bin/env bash

FILES=(/plex/rips/movies/*.mkv /plex/rips/series/*/*.mkv)

if [ "${#FILES}" -ne 0 ]; then

  for SOURCE in "${FILES[@]}"; do

    # Random micro sleep to mitigate simultaneous startup race condition.
    sleep .${RANDOM:1:2}

    # Find a file that isn't already in progress or transcoded
    if [ -f "${SOURCE%.mkv}.inprogress" ] || [ -f "${SOURCE%.mkv}.transcoded" ] || [ ! -f "${SOURCE}" ]; then
      continue
    fi

    # Claim the file
    touch "${SOURCE%.mkv}.inprogress"

    # Setup a temporary workspace on local storage
    cd $(mktemp -d -p /tmp/transcode)
    mkdir src

    # Copy the source to the local system
    echo "Copying ${SOURCE##*/}..."
    cp "${SOURCE}" src/

    # Verify the copied source file
    echo "Calculating ckecksums ..."
    ORIG=$(md5sum "${SOURCE}" | cut -d' ' -f1)
    NEW=$(md5sum "src/${SOURCE##*/}" | cut -d' ' -f1)

    if [ "${NEW}" != "${ORIG}" ]; then
      echo "Checksum mismatch!"
      echo "ORIG = ${ORIG}"
      echo "NEW = ${NEW}"
      rm "${SOURCE%.mkv}.inprogress"
      exit 1
    fi

    # Transcode!
    echo "Transcoding ${SOURCE##*/} ..."
    /usr/local/bin/classic-transcode "src/${SOURCE##*/}"

    # The exit code can't be trusted, so do a sanity check based on duration.
    # The duration check can also generate false positives, so it's only used
    #  here as a warning, with the discrepancy being written to the .transcoded
    #  file just in case there's an actual issue with the transcode.
    echo "Performing duration check ..."
    ORIG=$(/usr/local/bin/ffprobe "src/${SOURCE##*/}" 2>&1 | awk '/Duration/ { print $2 }' | cut -d'.' -f1)
    NEW=$(/usr/local/bin/ffprobe "${SOURCE##*/}" 2>&1 | awk '/Duration/ { print $2 }' | cut -d'.' -f1)

    # Copy the transcode to the Plex library, and clean up.

    # If original's parent directory doesn't exist, create it.
    DIR="${SOURCE%/*}"
    if [ ! -d "${DIR/rips/originals}" ]; then
      mkdir -p "${DIR/rips/originals}"
    fi

    echo "Moving ${SOURCE##*/} to originals ..."
    mv "${SOURCE}" "${SOURCE/rips/originals}"

    echo "Placing transcoded ${SOURCE##*/} into library ..."
    cp "${SOURCE##*/}" "${SOURCE}"

    echo "Marking as complete ..."
    rm "${SOURCE%.mkv}.inprogress"
    touch "${SOURCE%.mkv}.transcoded"

    if [ "${NEW}" != "${ORIG}" ]; then
      echo "Transcode duration (${NEW}) doesn't match source duration (${ORIG})!" > "${SOURCE%.mkv}.transcoded"
    fi

    echo "Cleaning up tmp space ..."
    rm -rf /tmp/transcode/tmp.*

  done

fi

