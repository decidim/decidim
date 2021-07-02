# frozen_string_literal: true

# This is an override for:
# https://github.com/rails/rails/blob/main/railties/lib/rails/all.rb

# This file is needed because of two reasons:
# 1. To remove the sprockets dependency from Rails
# 2. To remove the railtie includes that are not necessary for running Decidim

require "rails"

%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
).each do |railtie|
  require railtie
end
