FROM ruby:2.4.2-alpine
MAINTAINER david.morcillo@codegram.com
WORKDIR /decidim

RUN apk add --update nodejs 
RUN apk add --update git

RUN apk add --update ruby-dev build-base \
    libxml2-dev libxslt-dev pcre-dev libffi-dev \
    postgresql-dev

RUN apk add --update tzdata

RUN git init .
COPY .gitignore .

COPY Gemfile .
COPY Gemfile.lock .

COPY decidim.gemspec decidim.gemspec
COPY lib/decidim/version.rb lib/decidim/version.rb

COPY decidim-core/decidim-core.gemspec decidim-core/decidim-core.gemspec
COPY decidim-core/lib/decidim/core/version.rb decidim-core/lib/decidim/core/version.rb

COPY decidim-participatory_processes/decidim-participatory_processes.gemspec decidim-participatory_processes/decidim-participatory_processes.gemspec
COPY decidim-participatory_processes/lib/decidim/participatory_processes/version.rb decidim-participatory_processes/lib/decidim/participatory_processes/version.rb

COPY decidim-assemblies/decidim-assemblies.gemspec decidim-assemblies/decidim-assemblies.gemspec
COPY decidim-assemblies/lib/decidim/assemblies/version.rb decidim-assemblies/lib/decidim/assemblies/version.rb

COPY decidim-system/decidim-system.gemspec decidim-system/decidim-system.gemspec
COPY decidim-system/lib/decidim/system/version.rb decidim-system/lib/decidim/system/version.rb

COPY decidim-admin/decidim-admin.gemspec decidim-admin/decidim-admin.gemspec
COPY decidim-admin/lib/decidim/admin/version.rb decidim-admin/lib/decidim/admin/version.rb

COPY decidim-dev/decidim-dev.gemspec decidim-dev/decidim-dev.gemspec
COPY decidim-dev/lib/decidim/dev/version.rb decidim-dev/lib/decidim/dev/version.rb

COPY decidim-api/decidim-api.gemspec decidim-api/decidim-api.gemspec
COPY decidim-api/lib/decidim/api/version.rb decidim-api/lib/decidim/api/version.rb

COPY decidim-pages/decidim-pages.gemspec decidim-pages/decidim-pages.gemspec
COPY decidim-pages/lib/decidim/pages/version.rb decidim-pages/lib/decidim/pages/version.rb

COPY decidim-comments/decidim-comments.gemspec decidim-comments/decidim-comments.gemspec
COPY decidim-comments/lib/decidim/comments/version.rb decidim-comments/lib/decidim/comments/version.rb

COPY decidim-meetings/decidim-meetings.gemspec decidim-meetings/decidim-meetings.gemspec
COPY decidim-meetings/lib/decidim/meetings/version.rb decidim-meetings/lib/decidim/meetings/version.rb

COPY decidim-proposals/decidim-proposals.gemspec decidim-proposals/decidim-proposals.gemspec
COPY decidim-proposals/lib/decidim/proposals/version.rb decidim-proposals/lib/decidim/proposals/version.rb

COPY decidim-budgets/decidim-budgets.gemspec decidim-budgets/decidim-budgets.gemspec
COPY decidim-budgets/lib/decidim/budgets/version.rb decidim-budgets/lib/decidim/budgets/version.rb

COPY decidim-surveys/decidim-surveys.gemspec decidim-surveys/decidim-surveys.gemspec
COPY decidim-surveys/lib/decidim/surveys/version.rb decidim-surveys/lib/decidim/surveys/version.rb

COPY decidim-accountability/decidim-accountability.gemspec decidim-accountability/decidim-accountability.gemspec
COPY decidim-accountability/lib/decidim/accountability/version.rb decidim-accountability/lib/decidim/accountability/version.rb

RUN bundle install

COPY package.json .
COPY package-lock.json .

RUN npm i

COPY . .
