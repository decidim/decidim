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
      add_decidim_page_title(tags[:title])

      provide(:meta_description, tags[:description])
      provide(:meta_url, tags[:url])
      provide(:twitter_handler, tags[:twitter_handler])
      provide(:meta_image_url, tags[:image_url])
    end

    def add_decidim_page_title(title)
      @title ||= []
      @title << title
    end

    def decidim_page_title
      (@title || []).join(" - ")
    end
  end
end
