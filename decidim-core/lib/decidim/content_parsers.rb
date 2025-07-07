# frozen_string_literal: true

# This module provides a collection of content parsers for Decidim.
# Each parser is responsible for processing and transforming specific types of content,
# such as user mentions, links, blobs, and inline images.
#
# You can use these parsers by referencing their symbolic names with Decidim's content processor.
# For example, to parse inline images in content, use the :inline_images parser:
#
#   Decidim::ContentProcessor.parse_with_processor(:inline_images, content, options)
#
# Available parsers include:
#   :inline_images, :blob, :user, :link, :tag, :mention_resource, :resource, :newline, :base
#
# See each parser's documentation for details on their specific behavior.
module Decidim
  module ContentParsers
    autoload :BaseParser, "decidim/content_parsers/base_parser"
    autoload :BlobParser, "decidim/content_parsers/blob_parser"
    autoload :UserParser, "decidim/content_parsers/user_parser"
    autoload :NewlineParser, "decidim/content_parsers/newline_parser"
    autoload :LinkParser, "decidim/content_parsers/link_parser"
    autoload :InlineImagesParser, "decidim/content_parsers/inline_images_parser"
    autoload :ResourceParser, "decidim/content_parsers/resource_parser"
    autoload :TagParser, "decidim/content_parsers/tag_parser"
    autoload :MentionResourceParser, "decidim/content_parsers/mention_resource_parser"
  end
end
