# frozen_string_literal: true

# This is an override for:
# https://github.com/rails/rails/blob/main/railties/lib/rails/all.rb

# This file is needed to remove the sprockets dependency from Rails.

require "rails"

%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  action_mailbox/engine
  action_text/engine
  rails/test_unit/railtie
).each do |railtie|
  require railtie
end
