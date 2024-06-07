# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with the page meta tags.
  module MetaTagsHelper
    # Sets the given metatags for the page. It is a wrapper for the individual
    # methods, so that you can set multiple values with a single call. See the docs for
    # the other methods to see how they work.
    #
    # @param [Hash] tags - A Hash containing the meta tag name as keys and its content as values.
    # @param [Object, nil] resource - The resource object that may contain the image.
    #
    # @return [nil]
    def add_decidim_meta_tags(tags, resource = nil)
      add_decidim_page_title(tags[:title])
      add_decidim_meta_description(tags[:description])
      add_decidim_meta_url(tags[:url])
      add_decidim_meta_twitter_handler(tags[:twitter_handler])
      add_decidim_meta_image_url(determine_image_url(tags, resource))
    end

    # Adds base URL to the given path if it doesn't include a host.
    #
    # @param [String] path - A String containing the path (e.g. "/proposals/1").
    #
    # @return [String] - A String with the base URL and path, or the original path if it already includes a host.
    def add_base_url_to(path)
      return path if path.blank? || URI.parse(path).host.present?

      "#{resolve_base_url}#{path}"
    end

    # Determines the image URL to be used for meta tags.
    #
    # @param [Hash] tags - A Hash containing the meta tag name as keys and its content as values.
    # @param [Object] resource - The resource object that may contain the image.
    #
    # @return [String] - A String of the absolute URL of the image.
    def determine_image_url(tags, resource)
      return add_base_url_to(tags[:image_url]) if tags[:image_url].present?

      return nil unless resource

      if resource.respond_to?(:attachments)
        attachment_image = resource.attachments.where(content_type: %w(image/jpeg image/png)).first
        return add_base_url_to(attachment_image.url) if attachment_image
      end

      description_image_url = image_in_description(resource)
      return add_base_url_to(description_image_url) if description_image_url.present?

      space_image_url = participatory_space_image_url(resource)
      add_base_url_to(space_image_url) if space_image_url.present?
    end

    # Extracts the first image URL from the resource description.
    #
    # @param [Object] resource - The resource object that contains the body.
    #
    # @return [String] - A String of the relative URL of the first image found in the body.
    def extract_image_from_description(resource)
      return nil unless resource.respond_to?(:body) && resource.body.present?

      body_html = resource.body[I18n.locale.to_s]
      doc = Nokogiri::HTML(body_html)
      doc.css("img").map { |img| img["src"] }.first
    end

    # Resolves the base URL (example: https://www.decidim.org) without URL parameters.
    #
    # @return [String] - A String of the base URL.
    def resolve_base_url
      return request.base_url if respond_to?(:request) && request&.base_url.present?

      uri = URI.parse(decidim.root_url(host: current_organization.host))
      port = uri.port.present? && [80, 443].exclude?(uri.port) ? ":#{uri.port}" : ""

      "#{uri.scheme}://#{uri.host}#{port}"
    end

    #  Accumulates the given `title` so that they can be chained. Since Rails views
    # are rendered inside-out, `title` is appended to an array. This way the beginning of
    # the title will be the most specific one. Use the `decidim_page_title` method to
    # render the title whenever you need to (most surely, in the `<title>` tag in the HTML
    # head and in some `title` metatags).
    #
    # @example
    #   add_decidim_page_title("My Process")
    #   add_decidim_page_title("My Organization")
    #   decidim_page_title # => "My Process - My Organization"
    #
    # @param [String] title - A String to be added to the title
    #
    # @return [Array<String>]
    def add_decidim_page_title(title)
      @decidim_page_title ||= []
      @decidim_page_title << title if title.present?
      @decidim_page_title
    end

    # Renders the title for a page. Use the `add_decidim_page_title` method to
    # accumulate elements for the title. Basically, it joins the elements of the title
    # array with `" - "`.
    #
    # @return [String] - The concatenated title.
    def decidim_page_title
      (@decidim_page_title || []).join(" - ")
    end

    attr_reader :decidim_meta_description, :decidim_meta_url, :decidim_meta_image_url, :decidim_meta_twitter_handler

    # Sets the meta description for the current page. We want to keep the most specific
    # one, so you cannot replace the description if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # @param [String] description - The String to be set as description.
    #
    # @return [nil]
    def add_decidim_meta_description(description)
      @decidim_meta_description ||= strip_tags(description)
    end

    # Sets the meta Twitter handler for the current page. We want to keep the most specific
    # one, so you cannot replace the Twitter handler if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # @param [String] twitter_handler - The String to be set as Twitter handler.
    #
    # @return [nil]
    def add_decidim_meta_twitter_handler(twitter_handler)
      @decidim_meta_twitter_handler ||= twitter_handler
    end

    # Sets the meta URL for the current page. We want to keep the most specific
    # one, so you cannot replace the URL if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # @param [String] url - The String to be set as URL.
    #
    # @return [nil]
    def add_decidim_meta_url(url)
      @decidim_meta_url ||= url
    end

    # Sets the meta image URL for the current page. We want to keep the most specific
    # one, so you cannot replace the image URL if it is set by a view that has already
    # been rendered. Remember that Rails's views are render inside-out, so the `layout`
    # is the last one to be rendered. You can put there a basic content and override it
    # in other layers.
    #
    # @param [String] image_url - The String to be set as image URL.
    #
    # @return [nil]
    def add_decidim_meta_image_url(image_url)
      @decidim_meta_image_url ||= image_url
    end

    def participatory_space_image_url(resource)
      resource.participatory_space&.attached_uploader(:hero_image)&.path
    end

    def image_in_description(resource)
      extract_image_from_description(resource)
    end
  end
end
