# frozen_string_literal: true

require "decidim/system/engine"

module Decidim
  # This module contains all the logic related to a system-wide
  # administration panel. The scope of the domain is to be able
  # to manage Organizations (tenants), as well as have a bird's
  # eye view of the whole system.
  #
  module System
    include ActiveSupport::Configurable

    # The length of API secrets generated for API users.
    config_accessor :api_users_secret_length do
      ENV.fetch("DECIDIM_SYSTEM_API_USERS_SECRET_LENGTH", 32)
    end
  end
end
