# frozen_string_literal: true
module Decidim
  module Pages
    class Page
      def initialize(component)
        @component = component
      end

      def content
        return @content if defined?(@content)

        content = @component.configuration.try(:[], "content")
        content = content ? JSON.parse(content) : {}

        @content = content
      end

      attr_writer :content

      def save!
        @component.update_attributes!(
          configuration: { content: JSON.dump(content) }
        )
      end
    end
  end
end
