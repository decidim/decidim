# frozen_string_literal: true

module Decidim
  module ContentParsers
    autoload :Context, "decidim/content_parsers/context"
    autoload :BaseParser, "decidim/content_parsers/base_parser"
    autoload :UserParser, "decidim/content_parsers/user_parser"
  end
end
