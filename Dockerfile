FROM ruby:2.4.0
MAINTAINER david.morcillo@codegram.com

ENV APP_HOME /decidim

RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash && \
    apt-get install -y nodejs yarn

ADD Gemfile /tmp/Gemfile
ADD Gemfile.common /tmp/Gemfile.common
ADD Gemfile.lock /tmp/Gemfile.lock
ADD decidim.gemspec /tmp/decidim.gemspec

ADD decidim-core/decidim-core.gemspec /tmp/decidim-core/decidim-core.gemspec
ADD decidim-core/lib/decidim/core/version.rb /tmp/decidim-core/lib/decidim/core/version.rb
ADD decidim-system/decidim-system.gemspec /tmp/decidim-system/decidim-system.gemspec
ADD decidim-admin/decidim-admin.gemspec /tmp/decidim-admin/decidim-admin.gemspec
ADD decidim-dev/decidim-dev.gemspec /tmp/decidim-dev/decidim-dev.gemspec
ADD decidim-api/decidim-api.gemspec /tmp/decidim-api/decidim-api.gemspec
ADD decidim-pages/decidim-pages.gemspec /tmp/decidim-pages/decidim-pages.gemspec
ADD decidim-comments/decidim-comments.gemspec /tmp/decidim-comments/decidim-comments.gemspec
ADD decidim-meetings/decidim-meetings.gemspec /tmp/decidim-meetings/decidim-meetings.gemspec
ADD decidim-proposals/decidim-proposals.gemspec /tmp/decidim-proposals/decidim-proposals.gemspec

ADD package.json /tmp/package.json
ADD yarn.lock /tmp/yarn.lock

RUN cd /tmp && bundle install && yarn

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
