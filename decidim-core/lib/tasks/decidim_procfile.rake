# frozen_string_literal: true

require "thor"

namespace :decidim do
  namespace :procfile do
    desc "Generates a script for starting the development app server"
    task :install do
      actions :create_file, "Procfile.dev", <<~RUBY
        web: bin/rails server -b 0.0.0.0 -p 3000
        shakapacker: bin/shakapacker-dev-server
      RUBY

      if defined?(Sidekiq)
        actions :append_file, "Procfile.dev", <<~RUBY
          sidekiq: bundle exec sidekiq -C config/sidekiq.yml
        RUBY
      end

      actions :create_file, "bin/dev", %(#!/usr/bin/env sh

set -e

bundle check || bundle install --jobs 20 --retry 5

bin/rails decidim:upgrade db:migrate

if ! gem list foreman -i --silent; then
  echo "Installing foreman..."
  gem install foreman
fi

exec foreman start -f Procfile.dev "$@")

      actions :chmod, "bin/dev", 0o755
    end

    private

    class Actions < Thor
      include Thor::Actions
    end

    def actions(*)
      Actions.new.send(*)
    end
  end
end
