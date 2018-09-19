# frozen_string_literal: true

require "decidim/debates/admin"
require "decidim/debates/engine"
require "decidim/debates/admin_engine"
require "decidim/debates/component"

module Decidim
  # Base module for this engine.
  module Debates
    autoload :DebateSerializer, "decidim/debates/debate_serializer"
  end
end
