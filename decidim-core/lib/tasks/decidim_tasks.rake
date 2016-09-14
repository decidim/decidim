# frozen_string_literal: true
# desc "Explaining what the task does"
# task :decidim do
#   # Task goes here
# end

namespace :decidim do
  task upgrade: ["railties:install:migrations"]
end
