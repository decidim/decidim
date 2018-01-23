#!/bin/sh -x

# https://github.com/docker-library/ruby/issues/66
export BUNDLE_PATH=$GEM_HOME
export BUNDLE_BIN=$GEM_HOME/bin
export BUNDLE_APP_CONFIG=$GEM_HOME/config

export USER_UID=`stat -c %u /code/Gemfile`
export USER_GID=`stat -c %g /code/Gemfile`

usermod -u $USER_UID decidim 2> /dev/null
groupmod -g $USER_GID decidim 2> /dev/null
usermod -g $USER_GID decidim 2> /dev/null

chown -R -h $USER_UID $GEM_HOME 2> /dev/null
chgrp -R -h $USER_GID $GEM_HOME 2> /dev/null

/usr/bin/sudo -EH -u decidim "$@"
