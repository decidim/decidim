# frozen_string_literal: true

require "decidim/sortitions/admin"
require "decidim/sortitions/api"
require "decidim/sortitions/engine"
require "decidim/sortitions/admin_engine"
require "decidim/sortitions/component"

module Decidim
  # Base module for this engine.
  module Sortitions
    include ActiveSupport::Configurable

    # Public setting that defines how many elements will be shown
    # per page inside the administration view.
    config_accessor :items_per_page do
      15
    end

    # Link to algorithm used for the sortition
    config_accessor :sortition_algorithm do
      "https://ruby-doc.org/core-2.4.0/Random.html"
    end
  end
end
