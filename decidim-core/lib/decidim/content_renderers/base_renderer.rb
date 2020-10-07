# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # Abstract base class for content renderers, so they have the same contract
    #
    # @example How to use a content renderer class
    #   renderer = Decidim::ContentRenderers::CustomRenderer.new(content)
    #   parser.render # returns the content formatted
    #
    # @abstract Subclass and override {#render} to implement a content renderer
    class BaseRenderer
      # @return [String] the content to be formatted
      attr_reader :content

      # Gets initialized with the `content` to format
      #
      # @param content [String] content to be formatted
      def initialize(content)
        @content = content || ""
      end

      # Format the content and return it ready to display
      #
      # @example Implementation to display prohibited words
      #   def render
      #     content.gsub(/\~\~(.*?)\~\~/, '<del>\1</del>')
      #   end
      #
      # @abstract Subclass is expected to implement it
      # @return [String] the content processed and ready to display
      def render(_options = nil)
        content
      end
    end
  end
end
