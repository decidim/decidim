# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with the page meta tags.
  module MetaTagsHelper
    # Public: Sets the given metatags for the page. It's a wrapper for the individual
    # methods, so that you can set multiple values with a single call. See the docs for
    # the other methods to see how they work.
    #
    # tags - A Hash containing the meta tag name as keys and its content as values.
    #
    # Returns nothing.
    def add_decidim_meta_tags(tags)
      add_decidim_page_title(tags[:title])
      add_decidim_meta_description(tags[:description])
      add_decidim_meta_url(tags[:url])
      add_decidim_meta_twitter_handler(tags[:twitter_handler])
      add_decidim_meta_image_url(add_base_url_to(tags[:image_url]))
    end

    # Public: Add base url to path if path doesn't include host.
    # path - A String containing path (e.g. "/proposals/1" )
    # Returns a String of URL including base URL and path, or path if it's blank.
    def add_base_url_to(path)
      return path if path.blank?
      return path if URI.parse(path).host.present?

      "#{resolve_base_url}#{path}"
    end

    # Public: Resolve base url (example: https://www.decidim.org) without url params
    # Returns a String of base URL
    def resolve_base_url
      return request.base_url if respond_to?(:request) && request&.base_url.present?

      uri = URI.parse(decidim.root_url(host: current_organization.host))
      if uri.port.blank? || [80, 443].include?(uri.port)
        "#{uri.scheme}://#{uri.host}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end
    end

    # Public: Accumulates the given `title` so that they can be chained. Since Rails views
    # are rendered inside-out, `title` is appended to an array. This way the beggining of
    # the title will be the most specific one. Use the `decidim_page_title` method to
    # render the title whenever you need to (most surely, in the `<title>` tag in the HTML
    # head and in some `title` metatags).
    #
    # Example:
    #   add_decidim_page_title("My Process")
    #   add_decidim_page_title("My Organization")
    #   decidim_page_title # => "My Process - My Organization"
    #
    # title - A String to be added to the title
    #
    # Returns an Array of Strings.
    def add_decidim_page_title(title)
      @decidim_page_title ||= []
      return @decidim_page_title if title.blank?

      @decidim_page_title << title
    end

    # Public: Renders the title for a page. Use the `add_decidim_page_title` method to
    # accumulate elements for the title. Basically, it joins the elements of the title
    # array with `" - "`.
    #
    # Returns a String.
    def decidim_page_title
      (@decidim_page_title || []).join(" - ")
    end

    attr_reader :decidim_meta_description, :decidim_meta_url, :decidim_meta_image_url,
                :decidim_meta_twitter_handler

    # Sets the meta description for the current page. We want to keep the most specific
    # one, so you cannot replace the description if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # description - The String to be set as description
    #
    # Returns nothing.
    def add_decidim_meta_description(description)
      @decidim_meta_description ||= strip_tags(description)
    end

    # Sets the meta Twitter handler for the current page. We want to keep the most specific
    # one, so you cannot replace the Twitter handler if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # twitter_handler - The String to be set as Twitter handler
    #
    # Returns nothing.
    def add_decidim_meta_twitter_handler(twitter_handler)
      @decidim_meta_twitter_handler ||= twitter_handler
    end

    # Sets the meta URL for the current page. We want to keep the most specific
    # one, so you cannot replace the URL if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # url - The String to be set as URL
    #
    # Returns nothing.
    def add_decidim_meta_url(url)
      @decidim_meta_url ||= url
    end

    # Sets the meta image URL for the current page. We want to keep the most specific
    # one, so you cannot replace the image URL if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # image_url - The String to be set as image URL
    #
    # Returns nothing.
    def add_decidim_meta_image_url(image_url)
      @decidim_meta_image_url ||= image_url
    end
  end
end
