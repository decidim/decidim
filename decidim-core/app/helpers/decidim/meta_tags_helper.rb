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
    def add_decidim_meta_tags(tags)
      add_decidim_page_title(tags[:title])
      add_decidim_meta_description(tags[:description])
      add_decidim_meta_url(tags[:url])
      add_decidim_meta_twitter_handler(tags[:twitter_handler])
      add_decidim_meta_image_url(tags[:image_url])
    end

    def add_decidim_page_title(title)
      @decidim_page_title ||= []
      @decidim_page_title << title
    end

    def decidim_page_title
      (@decidim_page_title || []).join(" - ")
    end

    attr_reader :decidim_meta_description, :decidim_meta_url, :decidim_meta_image_url,
                :decidim_meta_twitter_handler

    def add_decidim_meta_description(description)
      @decidim_meta_description ||= strip_tags(description)
    end

    def add_decidim_meta_twitter_handler(twitter_handler)
      @decidim_meta_twitter_handler ||= twitter_handler
    end

    def add_decidim_meta_url(url)
      @decidim_meta_url ||= url
    end

    def add_decidim_meta_image_url(image_url)
      @decidim_meta_image_url ||= image_url
    end
  end
end
