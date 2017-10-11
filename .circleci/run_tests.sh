#!/bin/bash

engine=$1
testCommand=$2
branch=`git rev-parse --abbrev-ref HEAD`

if git diff --name-only $branch master | grep "^${engine}" ; then
  echo "YES"
  echo $testCommand
else
  echo "NO"
fi
