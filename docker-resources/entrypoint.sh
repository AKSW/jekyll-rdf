#!/bin/sh

bundle install
if [ $# -eq 0 ]
  then
    jekyll build
  else
    $@
fi
