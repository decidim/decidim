#!/bin/bash

shopt -s globstar

bundle exec erblint **/app/{cells,views}/**/*.erb

shopt -u globstar