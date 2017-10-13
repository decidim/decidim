#!/bin/bash

engine=$1
testCommand=$2
branch=`git rev-parse --abbrev-ref HEAD`

if [ "$branch" = "master" ]; then
  echo "YES, IT'S MASTER!!"
  eval $testCommand
elif git diff --name-only origin/master...$branch  | grep "^decidim-core" ; then
  echo "YES, CORE IS BEING MODIFIED"
  eval $testCommand
elif git diff --name-only origin/master...$branch  | grep "^${engine}" ; then
  echo "YES, THIS ENGINE IS BEING MODIFIED"
  eval $testCommand
else
  echo "NO"
fi
