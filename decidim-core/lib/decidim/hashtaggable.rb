# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to hashtaggable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      def search_title
        field = title
        field = if field.is_a?(String)
                  field
                elsif field.is_a?(Hash)
                  field.values.first
                end
        search_value_for(field)
      end

      alias_method :formatted_title, :search_title

      def search_body
        field = try(:body) || try(:description) || title
        field = if field.is_a?(Hash)
                  field
                elsif field.is_a?(Hash)
                  field.values.first
                end
        search_value_for(field)
      end

      alias_method :formatted_body, :search_body

      private

      def search_value_for(attribute)
        if attribute.is_a?(Hash)
          attribute.inject({}) do |rendered_value, (locale, content)|
            rendered_value.update(locale => render_hashtag_content(content))
          end
        else
          render_hashtag_content(attribute)
        end
      end

      def render_hashtag_content(content)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
        renderer.render(links: false).html_safe
      end
    end
  end
end
