#!/bin/bash

engine=$1
testCommand=$2
branch=`git rev-parse --abbrev-ref HEAD`
modifiedFiles="git diff --name-only $branch master"

if git diff --name-only $branch master | grep "^${engine}" ; then
  echo "YES"
  eval $testCommand
else
  echo "NO"
fi
