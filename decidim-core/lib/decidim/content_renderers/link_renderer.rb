# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that converts URLs to links and strips attributes in anchors.
    #
    # Examples:
    # `<a href="http://urls.net" onmouseover="alert('hello')">URLs</a>`
    # Gets rendered as:
    # `<a href="https://decidim.org" target="_blank" rel="noopener">https://decidim.org</a>`
    # And:
    # `<a href="javascript:document.cookies">click me</a>`
    # Gets rendered as:
    # `click me`
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class LinkRenderer < BaseRenderer
      # @return [String] the content ready to display (contains HTML)
      def render(options = {})
        return content unless content.is_a?(String)

        options = { target: "_blank", rel: "nofollow noopener" }.merge(options)
        Anchored::Linker.auto_link(content, options)
      end
    end
  end
end
