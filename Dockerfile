FROM deividrodriguez/ruby-2.4.2-rubygems-2.6.13:latest
MAINTAINER david.morcillo@codegram.com

ENV APP_HOME /decidim

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && \
    apt-get install -y nodejs

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock

ADD decidim.gemspec /tmp/decidim.gemspec
ADD lib/decidim/version.rb /tmp/lib/decidim/version.rb

ADD decidim-core/decidim-core.gemspec /tmp/decidim-core/decidim-core.gemspec
ADD decidim-core/lib/decidim/core/version.rb /tmp/decidim-core/lib/decidim/core/version.rb

ADD decidim-participatory_processes/decidim-participatory_processes.gemspec /tmp/decidim-participatory_processes/decidim-participatory_processes.gemspec
ADD decidim-participatory_processes/lib/decidim/participatory_processes/version.rb /tmp/decidim-participatory_processes/lib/decidim/participatory_processes/version.rb

ADD decidim-assemblies/decidim-assemblies.gemspec /tmp/decidim-assemblies/decidim-assemblies.gemspec
ADD decidim-assemblies/lib/decidim/assemblies/version.rb /tmp/decidim-assemblies/lib/decidim/assemblies/version.rb

ADD decidim-system/decidim-system.gemspec /tmp/decidim-system/decidim-system.gemspec
ADD decidim-system/lib/decidim/system/version.rb /tmp/decidim-system/lib/decidim/system/version.rb

ADD decidim-admin/decidim-admin.gemspec /tmp/decidim-admin/decidim-admin.gemspec
ADD decidim-admin/lib/decidim/admin/version.rb /tmp/decidim-admin/lib/decidim/admin/version.rb

ADD decidim-dev/decidim-dev.gemspec /tmp/decidim-dev/decidim-dev.gemspec
ADD decidim-dev/lib/decidim/dev/version.rb /tmp/decidim-dev/lib/decidim/dev/version.rb

ADD decidim-api/decidim-api.gemspec /tmp/decidim-api/decidim-api.gemspec
ADD decidim-api/lib/decidim/api/version.rb /tmp/decidim-api/lib/decidim/api/version.rb

ADD decidim-pages/decidim-pages.gemspec /tmp/decidim-pages/decidim-pages.gemspec
ADD decidim-pages/lib/decidim/pages/version.rb /tmp/decidim-pages/lib/decidim/pages/version.rb

ADD decidim-comments/decidim-comments.gemspec /tmp/decidim-comments/decidim-comments.gemspec
ADD decidim-comments/lib/decidim/comments/version.rb /tmp/decidim-comments/lib/decidim/comments/version.rb

ADD decidim-meetings/decidim-meetings.gemspec /tmp/decidim-meetings/decidim-meetings.gemspec
ADD decidim-meetings/lib/decidim/meetings/version.rb /tmp/decidim-meetings/lib/decidim/meetings/version.rb

ADD decidim-proposals/decidim-proposals.gemspec /tmp/decidim-proposals/decidim-proposals.gemspec
ADD decidim-proposals/lib/decidim/proposals/version.rb /tmp/decidim-proposals/lib/decidim/proposals/version.rb

ADD decidim-budgets/decidim-budgets.gemspec /tmp/decidim-budgets/decidim-budgets.gemspec
ADD decidim-budgets/lib/decidim/budgets/version.rb /tmp/decidim-budgets/lib/decidim/budgets/version.rb

ADD decidim-surveys/decidim-surveys.gemspec /tmp/decidim-surveys/decidim-surveys.gemspec
ADD decidim-surveys/lib/decidim/surveys/version.rb /tmp/decidim-surveys/lib/decidim/surveys/version.rb

ADD decidim-accountability/decidim-accountability.gemspec /tmp/decidim-accountability/decidim-accountability.gemspec
ADD decidim-accountability/lib/decidim/accountability/version.rb /tmp/decidim-accountability/lib/decidim/accountability/version.rb

ADD package.json /tmp/package.json
ADD package-lock.json /tmp/package-lock.json

RUN cd /tmp && bundle install && npm i

WORKDIR $APP_HOME
ADD . ./
