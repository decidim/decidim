# frozen_string_literal: true

require "decidim/admin/engine"

module Decidim
  # This module contains all the logic related to a admin-wide
  # administration panel. The scope of the domain is to be able
  # to manage Organizations (tenants), as well as have a bird's
  # eye view of the whole admin.
  #
  module Admin
    autoload :Features, "decidim/admin/features"
  end
end
