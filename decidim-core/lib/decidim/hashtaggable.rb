# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      def search_title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(title)
        renderer.render_without_link.html_safe
      end

      def search_body
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(body)
        renderer.render_without_link.html_safe
      end
    end
  end
end
