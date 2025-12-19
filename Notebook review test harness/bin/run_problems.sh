#!/bin/bash

DIRECTORY=$1
PLATFORM=$2

SCRIPT_DIR=$(dirname "$0")

for file in "$DIRECTORY"/*.pdf;
do
	file_no_ext="${file%.*}"
    echo $file_no_ext
    $SCRIPT_DIR/run_evaluation.py --platform "${PLATFORM}" --prompt-name significant_problems "${file}.openai.1.txt" > "${file_no_ext}.openai.1.problems.txt"
done