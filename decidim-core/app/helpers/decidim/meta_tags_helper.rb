# frozen_string_literal: true
module Decidim
  # Helper that provides convenient methods to deal with the page meta tags.
  module MetaTagsHelper
    # Public: Sets the given metatags for the page.
    #
    # tags - A Hash containing the meta tag name as keys and its content as
    # values.
    # flush - A Boolean indicating if this tags will flush the previous ones,
    # should there be any.
    #
    # Returns nothing.
    def add_meta_tags(tags, flush=true)
      content_for(:meta_title, tags[:title], flush: flush)
      content_for(:meta_description, tags[:description], flush: flush)
      content_for(:meta_url, tags[:url], flush: flush)
      content_for(:twitter_handler, tags[:twitter_handler], flush: flush)
      content_for(:meta_image_url, tags[:image_url], flush: flush)
    end
  end
end
