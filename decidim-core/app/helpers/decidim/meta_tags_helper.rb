# frozen_string_literal: true
module Decidim
  # Helper that provides convenient methods to deal with the page meta tags.
  module MetaTagsHelper
    # Public: Sets the given metatags for the page.
    #
    # tags - A Hash containing the meta tag name as keys and its content as
    # values.
    #
    # Returns nothing.
    def add_meta_tags(tags)
      provide(:meta_description, tags[:description]) unless content_for :meta_description
      provide(:meta_url, tags[:url]) unless content_for :meta_url
      provide(:twitter_handler, tags[:twitter_handler]) unless content_for :twitter_handler
      provide(:meta_image_url, tags[:image_url]) unless content_for :meta_image_url
    end
  end
end
