# frozen_string_literal: true

namespace :decidim do
  namespace :robots do
    desc "Overrides robots.txt with a custom one."
    task :replace, [] => :environment do
      actions :create_file, "public/robots.txt", <<~EOTASK
        # the following adds a rule for all bots to not index any page that contains a profile or search
        User-agent: *
        Disallow: /profiles/
        Disallow: /search
      EOTASK
    end
  end
end
