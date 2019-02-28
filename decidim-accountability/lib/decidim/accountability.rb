# frozen_string_literal: true

require "decidim/accountability/admin"
require "decidim/accountability/engine"
require "decidim/accountability/admin_engine"
require "decidim/accountability/component"

module Decidim
  # Base module for this engine.
  module Accountability
    autoload :ResultSerializer, "decidim/accountability/result_serializer"
  end
  module ContentParsers
    autoload :ResultParser, "decidim/content_parsers/result_parser"
  end

  module ContentRenderers
    autoload :ResultRenderer, "decidim/content_renderers/result_renderer"
  end
end
