#!/bin/sh

if [ -z "$NO_BUNDLER" ]
then
  bundle install
  if [ $# -eq 0 ]
  then
    bundle exec jekyll build
  else
    bundle exec $@
  fi
else
  $@
fi
