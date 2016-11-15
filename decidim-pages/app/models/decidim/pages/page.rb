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

      def content=(content)
        @content = content
      end

      def save!
        @component.update_attributes!(
          configuration: { content: JSON.dump(content)}
        )
      end
    end
  end
end
