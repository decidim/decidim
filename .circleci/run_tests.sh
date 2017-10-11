#!/bin/bash

engine=$1
testCommand=$2
branch=`git rev-parse --abbrev-ref HEAD`
echo $branch
modifiedFiles="git diff --name-only $branch master"

git checkout master
git reset --hard origin/master
git checkout -

if [ "$branch" = "master" ]; then
   echo "YES, IT'S MASTER!!"
   eval $testCommand
elif git diff --name-only $branch master | grep "^decidim-core" ; then
  echo "YES"
  eval $testCommand
elif git diff --name-only $branch master | grep "^${engine}" ; then
  echo "YES"
  eval $testCommand
else
  echo "NO"
fi
