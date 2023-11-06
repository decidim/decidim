# frozen_string_literal: true

require "thor"

namespace :decidim do
  namespace :procfile do
    desc "Generates a dummy app for testing in external installations"
    task :install do
      actions :create_file, "Procfile.dev", <<~RUBY
        web: bin/rails server -b 0.0.0.0 -p 3000
        shakapacker: bin/shakapacker-dev-server
      RUBY

      actions :create_file, "bin/dev", %(#!/usr/bin/env sh

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

    def actions(*args)
      Actions.new.send(*args)
    end
  end
end
