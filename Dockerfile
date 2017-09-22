FROM deividrodriguez/ruby-2.4.2-rubygems-2.6.13:latest
MAINTAINER david.morcillo@codegram.com

ENV APP_HOME /decidim

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && \
    apt-get install -y nodejs

COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock

COPY decidim.gemspec /tmp/decidim.gemspec
COPY lib/decidim/version.rb /tmp/lib/decidim/version.rb

COPY decidim-core/decidim-core.gemspec /tmp/decidim-core/decidim-core.gemspec
COPY decidim-core/lib/decidim/core/version.rb /tmp/decidim-core/lib/decidim/core/version.rb

COPY decidim-participatory_processes/decidim-participatory_processes.gemspec /tmp/decidim-participatory_processes/decidim-participatory_processes.gemspec
COPY decidim-participatory_processes/lib/decidim/participatory_processes/version.rb /tmp/decidim-participatory_processes/lib/decidim/participatory_processes/version.rb

COPY decidim-assemblies/decidim-assemblies.gemspec /tmp/decidim-assemblies/decidim-assemblies.gemspec
COPY decidim-assemblies/lib/decidim/assemblies/version.rb /tmp/decidim-assemblies/lib/decidim/assemblies/version.rb

COPY decidim-system/decidim-system.gemspec /tmp/decidim-system/decidim-system.gemspec
COPY decidim-system/lib/decidim/system/version.rb /tmp/decidim-system/lib/decidim/system/version.rb

COPY decidim-admin/decidim-admin.gemspec /tmp/decidim-admin/decidim-admin.gemspec
COPY decidim-admin/lib/decidim/admin/version.rb /tmp/decidim-admin/lib/decidim/admin/version.rb

COPY decidim-dev/decidim-dev.gemspec /tmp/decidim-dev/decidim-dev.gemspec
COPY decidim-dev/lib/decidim/dev/version.rb /tmp/decidim-dev/lib/decidim/dev/version.rb

COPY decidim-api/decidim-api.gemspec /tmp/decidim-api/decidim-api.gemspec
COPY decidim-api/lib/decidim/api/version.rb /tmp/decidim-api/lib/decidim/api/version.rb

COPY decidim-pages/decidim-pages.gemspec /tmp/decidim-pages/decidim-pages.gemspec
COPY decidim-pages/lib/decidim/pages/version.rb /tmp/decidim-pages/lib/decidim/pages/version.rb

COPY decidim-comments/decidim-comments.gemspec /tmp/decidim-comments/decidim-comments.gemspec
COPY decidim-comments/lib/decidim/comments/version.rb /tmp/decidim-comments/lib/decidim/comments/version.rb

COPY decidim-meetings/decidim-meetings.gemspec /tmp/decidim-meetings/decidim-meetings.gemspec
COPY decidim-meetings/lib/decidim/meetings/version.rb /tmp/decidim-meetings/lib/decidim/meetings/version.rb

COPY decidim-proposals/decidim-proposals.gemspec /tmp/decidim-proposals/decidim-proposals.gemspec
COPY decidim-proposals/lib/decidim/proposals/version.rb /tmp/decidim-proposals/lib/decidim/proposals/version.rb

COPY decidim-budgets/decidim-budgets.gemspec /tmp/decidim-budgets/decidim-budgets.gemspec
COPY decidim-budgets/lib/decidim/budgets/version.rb /tmp/decidim-budgets/lib/decidim/budgets/version.rb

COPY decidim-surveys/decidim-surveys.gemspec /tmp/decidim-surveys/decidim-surveys.gemspec
COPY decidim-surveys/lib/decidim/surveys/version.rb /tmp/decidim-surveys/lib/decidim/surveys/version.rb

COPY decidim-accountability/decidim-accountability.gemspec /tmp/decidim-accountability/decidim-accountability.gemspec
COPY decidim-accountability/lib/decidim/accountability/version.rb /tmp/decidim-accountability/lib/decidim/accountability/version.rb

RUN cd /tmp && bundle install

COPY package.json /tmp/package.json
COPY package-lock.json /tmp/package-lock.json

RUN cd /tmp && npm i

WORKDIR $APP_HOME
COPY . ./
