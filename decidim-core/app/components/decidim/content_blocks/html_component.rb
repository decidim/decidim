# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HtmlComponent < ContentBlockComponent

      def html_content
        translated_attribute(settings.html_content).html_safe
      end
    end
  end
end
