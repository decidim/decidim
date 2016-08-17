# desc "Explaining what the task does"
# task :decidim do
#   # Task goes here
# end

namespace :decidim do
  task upgrade: ['decidim:install:migrations']
end
