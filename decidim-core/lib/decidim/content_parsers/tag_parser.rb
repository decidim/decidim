# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches specific tags in the content. This is an abstract
    # class that provides some helper methods for parsing the content and the
    # implementation has to be defined by all the classes that inherit from this
    # class.
    #
    # @see BaseParser Examples of how to use a content parser
    class TagParser < BaseParser
      # Replaces tags name with new or existing tags models global ids.
      #
      # The actual tags depend on the context, these can be hashtags, user
      # mentions, etc.
      #
      # @return [String] the content with the tags replaced by global ids
      def rewrite
        if html_content?
          html_fragment.search("span[data-type='#{tag_data_type}']").each do |el|
            el.replace replace_tags(element_tag(el))
          end
          html_fragment.to_s
        else
          replace_tags(content)
        end
      end

      protected

      def tag_data_type
        raise NotImplementedError, "#{self.class.name} does not define tag_data_type"
      end

      def replace_tags(text)
        raise NotImplementedError, "#{self.class.name} does not define replace_tags"
      end

      def scan_tags(text)
        raise NotImplementedError, "#{self.class.name} does not define scan_tags"
      end

      def element_tag(element)
        element["data-id"] || element["data-label"] || element.content
      end

      def content_tags
        @content_tags ||= begin
          scannables =
            if html_content?
              html_fragment.search("span[data-type='#{tag_data_type}']").map do |el|
                element_tag(el)
              end
            else
              [content]
            end

          scannables.map { |str| scan_tags(str) }.flatten.uniq
        end
      end
    end
  end
end
