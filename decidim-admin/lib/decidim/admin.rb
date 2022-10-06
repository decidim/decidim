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
    autoload :SearchFormBuilder, "decidim/admin/search_form_builder"
    autoload :Import, "decidim/admin/import"

    include ActiveSupport::Configurable

    # Public Setting that configures Kaminari configuration options
    # https://github.com/kaminari/kaminari#general-configuration-options

    # Range of number of results per_page. Defaults to [15, 50, 100].
    # per_page_range.first sets the default number per page
    # per_page_range.last sets the default max_per_page
    config_accessor :per_page_range do
      [15, 50, 100]
    end

    Kaminari.configure do |config|
      config.default_per_page = Decidim::Admin.per_page_range.first
      config.max_per_page = Decidim::Admin.per_page_range.last
    end

    # Public: Stores an instance of ViewHooks
    def self.view_hooks
      @view_hooks ||= ViewHooks.new
    end
  end
end
