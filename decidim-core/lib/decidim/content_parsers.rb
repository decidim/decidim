# frozen_string_literal: true

module Decidim
  module ContentParsers
    autoload :BaseParser, "decidim/content_parsers/base_parser"
    autoload :UserParser, "decidim/content_parsers/user_parser"
    autoload :HashtagParser, "decidim/content_parsers/hashtag_parser"
  end
end
