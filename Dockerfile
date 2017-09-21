FROM ruby:2.4.2
MAINTAINER david.morcillo@codegram.com

ENV APP_HOME /decidim

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && \
    apt-get install -y nodejs
RUN gem install bundler --no-rdoc --no-ri

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
ADD decidim.gemspec /tmp/decidim.gemspec

ADD decidim-core/decidim-core.gemspec /tmp/decidim-core/decidim-core.gemspec
ADD decidim-core/lib/decidim/core/version.rb /tmp/decidim-core/lib/decidim/core/version.rb
ADD decidim-participatory_processes/decidim-participatory_processes.gemspec /tmp/decidim-participatory_processes/decidim-participatory_processes.gemspec
ADD decidim-assemblies/decidim-assemblies.gemspec /tmp/decidim-assemblies/decidim-assemblies.gemspec
ADD decidim-system/decidim-system.gemspec /tmp/decidim-system/decidim-system.gemspec
ADD decidim-admin/decidim-admin.gemspec /tmp/decidim-admin/decidim-admin.gemspec
ADD decidim-dev/decidim-dev.gemspec /tmp/decidim-dev/decidim-dev.gemspec
ADD decidim-api/decidim-api.gemspec /tmp/decidim-api/decidim-api.gemspec
ADD decidim-pages/decidim-pages.gemspec /tmp/decidim-pages/decidim-pages.gemspec
ADD decidim-comments/decidim-comments.gemspec /tmp/decidim-comments/decidim-comments.gemspec
ADD decidim-meetings/decidim-meetings.gemspec /tmp/decidim-meetings/decidim-meetings.gemspec
ADD decidim-proposals/decidim-proposals.gemspec /tmp/decidim-proposals/decidim-proposals.gemspec
ADD decidim-results/decidim-results.gemspec /tmp/decidim-results/decidim-results.gemspec
ADD decidim-budgets/decidim-budgets.gemspec /tmp/decidim-proposals/decidim-budgets.gemspec
ADD decidim-surveys/decidim-surveys.gemspec /tmp/decidim-surveys/decidim-surveys.gemspec

ADD package.json /tmp/package.json
ADD package-lock.json /tmp/package-lock.json

RUN cd /tmp && bundle install && npm i

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
