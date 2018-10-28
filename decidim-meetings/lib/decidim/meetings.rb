# frozen_string_literal: true

require "decidim/meetings/admin"
require "decidim/meetings/engine"
require "decidim/meetings/admin_engine"
require "decidim/meetings/directory"
require "decidim/meetings/directory_engine"
require "decidim/meetings/component"

module Decidim
  # Base module for this engine.
  module Meetings
    autoload :Registrations, "decidim/meetings/registrations"
  end
end
