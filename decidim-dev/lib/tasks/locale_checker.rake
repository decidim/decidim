# frozen_string_literal: true

namespace :decidim do
  desc "Allows a decidim installation to check whether its locales are complete"
  task check_locales: :environment do
    FileUtils.remove_dir("tmp/decidim_repo", true)

    branch = ENV["TARGET_BRANCH"] || "master"
    status = system("git clone --depth=1 --single-branch --branch #{branch} https://github.com/decidim/decidim tmp/decidim_repo")
    return unless status

    Dir.chdir("tmp/decidim_repo") do
      env = { "ENFORCED_LOCALES" => Decidim.available_locales.join(",") }

      Bundler.with_clean_env do
        system(env, "bundle install")
        system(env, "bundle exec rspec spec/i18n_spec.rb")
      end
    end
  end
end
