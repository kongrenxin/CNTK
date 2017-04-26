#!/bin/bash
set -e -o pipefail

LIB_PATH="$1"

export LD_LIBRARY_PATH=$LIB_PATH:$LD_LIBRARY_PATH
java -classpath "$LIB_PATH/java" Main
