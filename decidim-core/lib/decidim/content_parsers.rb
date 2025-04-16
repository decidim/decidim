# frozen_string_literal: true

module Decidim
  module ContentParsers
    autoload :BaseParser, "decidim/content_parsers/base_parser"
    autoload :BlobParser, "decidim/content_parsers/blob_parser"
    autoload :UserParser, "decidim/content_parsers/user_parser"
    autoload :HashtagParser, "decidim/content_parsers/hashtag_parser"
    autoload :NewlineParser, "decidim/content_parsers/newline_parser"
    autoload :LinkParser, "decidim/content_parsers/link_parser"
    autoload :InlineImagesParser, "decidim/content_parsers/inline_images_parser"
    autoload :ResourceParser, "decidim/content_parsers/resource_parser"
    autoload :TagParser, "decidim/content_parsers/tag_parser"
    autoload :MentionResourceParser, "decidim/content_parsers/mention_resource_parser"
  end
end
