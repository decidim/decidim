# frozen_string_literal: true

namespace :decidim do
  namespace :demographics do
    desc "Setup environment so that only decidim migrations are installed."
    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_demographics"
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:demographics:choose_target_plugins"].invoke
end
