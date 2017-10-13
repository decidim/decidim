#!/bin/bash

engine=$1
testCommand=$2
branch=`git rev-parse --abbrev-ref HEAD`

# git checkout master
# git reset --hard origin/master
# git checkout -

if [ "$branch" = "master" ]; then
  echo "YES, IT'S MASTER!!"
  eval $testCommand
elif git diff --name-only $branch origin/master | grep "^decidim-core" ; then
  echo "YES, CORE IS BEING MODIFIED"
  eval $testCommand
elif git diff --name-only $branch origin/master | grep "^${engine}" ; then
  echo "YES, THIS ENGINE IS BEING MODIFIED"
  eval $testCommand
else
  echo "NO"
fi
