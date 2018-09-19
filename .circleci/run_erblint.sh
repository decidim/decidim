#!/bin/bash

set -s globstar

bundle exec erblint **/app/{cells,views}/**/*.erb

set -u globstar