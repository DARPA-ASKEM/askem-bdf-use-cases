#!/bin/bash

DIRECTORY=$1
PROVIDER=$2
PLATFORM=$3

SCRIPT_DIR=$(dirname "$0")

for RUN in {1..10}
do
    for file in "$DIRECTORY"/*.pdf;
    do
        echo $file $RUN
        $SCRIPT_DIR/run_evaluation.py --platform "{PLATFORM}" --provider "${PROVIDER}" "${file}" > "${file}.${PROVIDER}.${RUN}.txt"
    done
done