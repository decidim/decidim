# frozen_string_literal: true

require "decidim/meetings/admin"
require "decidim/meetings/engine"
require "decidim/meetings/admin_engine"
require "decidim/meetings/component"

module Decidim
  # Base module for this engine.
  module Meetings
    autoload :ViewModel, "decidim/meetings/view_model"
    autoload :Registrations, "decidim/meetings/registrations"
  end
end
