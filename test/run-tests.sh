#!/usr/bin/env bash

# =====================================================
# This script runs Vader tests. You can specify 
# particular test or run all *.vader from the ./test/
# directory just ommiting particular test:
#
# > run-tests.sh unit_tests.vader
#
# or to run all tests:
#
# > run-tests.sh
#
# Nevertheless, how you run tests, every 
# test will be run in separate vim process.
#
# To run tests `vader.vim` needed. You have two ways 
# to use `vader.vim`. The first one is set `VADER_PATH`.
# By default `VADER_PATH` is '~/.vim/plugged/vader.vim/'.
# If path from the `VADER_PATH` is absent, 
# 'https://github.com/junegunn/vader.vim' will be cloned 
# to the temp directory which will be used as the 
# `VADER_PATH`.
# ====================================================


# got to the directory with this script (./test/):
cd $(dirname ${BASH_SOURCE[0]})

# path to the Vader plugin:
VADER_PATH=${VADER_PATH:="${HOME}/.vim/plugged/vader.vim/"}

if ! [[ -d $VADER_PATH ]]
then
  VADER_PATH=$(mktemp -d)
  echo 'Clone the vader.vim to the '$VADER_PATH
  git clone --depth=1 'https://github.com/junegunn/vader.vim.git' "$VADER_PATH"
  echo 'cloned.'
fi
        

# path to the directory with plugin for test:
PLUGIN_PATH=${PLUGIN_PATH:='../'}

# regexp to select tests to run
[[ -z "$1" ]] && VADER_TESTS=*.vader || VADER_TESTS="$1"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

VADER_RESULTS=("${GREEN}Results:$NC")
RESULT=0
VIMRC="filetype off | set rtp+=$VADER_PATH | set rtp+=$PLUGIN_PATH | filetype plugin indent on | syntax enable"

echo $VIMRC

function run() {
  echo "Run $1"

  vim -EsNu <(echo $VIMRC) -c "Vader! $1"

  if [[ $? == 0 ]]
  then
    VADER_RESULTS+=("$GREEN + SUCCESS: $1 $NC")
  else
    VADER_RESULTS+=("$RED - FAIL: $1 $NC")
    RESULT=1
  fi
}

for test in $VADER_TESTS; do run $test; done

printf '%b\n' "${VADER_RESULTS[@]}"

exit $RESULT

