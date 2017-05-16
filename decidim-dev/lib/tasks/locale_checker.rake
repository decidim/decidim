# frozen_string_literal: true

namespace :decidim do
  desc "Allows a decidim installation to check whether its locales are complete"
  task :check_locales do
    env = {
      "BUNDLE_GEMFILE" => File.expand_path("Gemfile"),
      "ENFORCED_LOCALES" => Decidim.available_locales.join(",")
    }

    Bundler.definition.specs.each do |spec|
      next unless spec.name =~ /decidim-/

      Dir.chdir(spec.full_gem_path) do
        Bundler.with_clean_env do
          system(env, "bundle exec rspec spec/i18n_spec.rb")
        end
      end
    end
  end
end
