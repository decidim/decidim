# frozen_string_literal: true

namespace :decidim do
  namespace :robots do
    desc "Overrides robots.txt with a custom one."
    task :replace, [] => :environment do
      actions :append_file, "public/robots.txt", <<~SQUISH
        # the following adds a rule for all bots to not index any page that contains a profile or search
        User-agent: *
        Disallow: /profiles/
        Disallow: /search
      SQUISH
    end
  end
end
