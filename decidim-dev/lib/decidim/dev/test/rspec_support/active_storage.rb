# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example, :disk_storage_host) do
    # Needed for the asset URLs to work through the local disk service when the
    # asset URLs are requested outside of a request context.
    #
    # Normally this would be set by the controller through the
    # `ActiveStorage::SetCurrent` concern when the storage URLs are requested
    # within a normal request context.
    ActiveStorage::Current.host = "http://localhost:#{Capybara.server_port}"
  end
end
