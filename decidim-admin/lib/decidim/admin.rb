# frozen_string_literal: true

require "decidim/admin/engine"

module Decidim
  # This module contains all the logic related to a admin-wide
  # administration panel. The scope of the domain is to be able
  # to manage Organizations (tenants), as well as have a bird's
  # eye view of the whole admin.
  #
  module Admin
    autoload :Components, "decidim/admin/components"
    autoload :FormBuilder, "decidim/admin/form_builder"

    include ActiveSupport::Configurable

    # Public Setting that configures Kaminari configuration options
    # https://github.com/kaminari/kaminari#general-configuration-options

    # Number of items per_page. Defaults to 15.
    config_accessor :default_per_page do
      15
    end

    # Max number of items per_page. Defaults to 100.
    config_accessor :max_per_page do
      100
    end

    Kaminari.configure do |config|
      config.default_per_page = Decidim::Admin.default_per_page
      config.max_per_page = Decidim::Admin.max_per_page
    end
  end
end
