# frozen_string_literal: true

module Decidim
  module ContentRenderers
    autoload :BaseRenderer, "decidim/content_renderers/base_renderer"
    autoload :BlobRenderer, "decidim/content_renderers/blob_renderer"
    autoload :UserRenderer, "decidim/content_renderers/user_renderer"
    autoload :HashtagRenderer, "decidim/content_renderers/hashtag_renderer"
    autoload :LinkRenderer, "decidim/content_renderers/link_renderer"
    autoload :ResourceRenderer, "decidim/content_renderers/resource_renderer"
    autoload :MentionResourceRenderer, "decidim/content_renderers/mention_resource_renderer"
  end
end
