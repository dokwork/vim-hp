#!/usr/bin/env bash

# got to the directory with this script (test/):
cd $(dirname ${BASH_SOURCE[0]})

# export path to the Vader plugin:
export VADER_PATH=${VADER_PATH:='~/.vim/plugged/vader.vim/'}

# export path to the Vader's test files:
export VIM_HP_PATH=${VIM_HP_PATH:='../'}

TEST='*'

vim -Nu vimrc -c "Vader! $TEST"
