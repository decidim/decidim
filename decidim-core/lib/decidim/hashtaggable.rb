# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to hashtaggable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      def search_title
        value = try(:i18n_title) || title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(value)
        renderer.render(links: false).html_safe
      end

      alias_method :formatted_title, :search_title

      def search_body
        value = try(:i18n_body) || try(:body) || try(:description) || title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(value)
        renderer.render(links: false).html_safe
      end

      alias_method :formatted_body, :search_body
    end
  end
end
