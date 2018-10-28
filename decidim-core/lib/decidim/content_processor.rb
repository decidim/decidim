# frozen_string_literal: true

module Decidim
  # This module contains all logic related to decidim's ability for process a content.
  # Their main job is to {ContentProcessor#parse parse} or {ContentProcessor#render render}
  # a content calling all the registered processors in the Decidim.content_processors config.
  #
  # Note that to render a content this must have been parsed before.
  #
  # When creating a new processor, the both sides must be declared: parser and renderer
  # e.g. If we are creating a processor to parse and render user mentions, we can call this
  # the `user` processor, so we will declare the parser and renderer classes like that:
  #
  #   Decidim::ContentParsers::UserParser
  #   Decidim::ContentRenderers::UserRenderer
  #
  # and register it in an initializer, so it is executed:
  #
  #   Decidim.content_processors += [:user]
  #
  # If for some reason you only want to do something in one of the both sides, please, also
  # declare the other side making it "transparent" (declaring the class and leaving it empty).
  #
  # @example How to parse a content
  #   parsed = Decidim::ContentProcessor.parse(content, context)
  #   parsed.rewrite # contains rewritten content
  #   parsed.metadata # contains the merged metadata of all parsers
  #
  # @example How to render a content (must have been parsed before)
  #   rendered = Decidim::ContentProcessor.render(content)
  #   puts rendered
  module ContentProcessor
    extend ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::TagHelper
    extend ActionView::Helpers::TextHelper

    # Class that represents the result of processing a text
    #
    # @!attribute rewrite
    #   @return [String] the rewritten content
    # @!attribute metadata
    #   @return [Hash<Symbol, Metadata>] a hash where the keys are the parsers
    #     names, and the values are the Metadata object returned by the parser
    Result = Struct.new(:rewrite, :metadata)

    # This calls all registered processors one after the other and collects the
    # metadata for each one and the resulting modified content
    #
    # @param content [String] already rewritten content or regular content
    # @param context [Hash] with information to inject to the parsers as context
    #
    # @return [Result] a Result object with the content rewritten and the metadata
    def self.parse(content, context)
      parsed = Decidim.content_processors.each_with_object(rewrite: content, metadata: {}) do |type, result|
        parser = parser_klass(type).constantize.new(result[:rewrite], context)
        result[:rewrite] = parser.rewrite
        result[:metadata][type] = parser.metadata
      end

      Result.new(parsed[:rewrite], parsed[:metadata])
    end

    def self.parse_with_processor(_type, content, context)
      parsed = if content.is_a?(Hash)
                 Decidim.content_processors.each_with_object(rewrite: content, metadata: {}) do |type, result|
                   next unless type == :hashtag
                   result[:rewrite].each do |key, value|
                     parser = parser_klass(type).constantize.new(value, context)
                     result[:rewrite][key] = parser.rewrite
                     result[:metadata][type] = parser.metadata
                   end
                 end
               else
                 Decidim.content_processors.each_with_object(rewrite: content, metadata: {}) do |type, result|
                   next unless type == :hashtag
                   parser = parser_klass(type).constantize.new(result[:rewrite], context)
                   result[:rewrite] = parser.rewrite
                   result[:metadata][type] = parser.metadata
                 end
               end
      Result.new(parsed[:rewrite], parsed[:metadata])
    end

    # This calls all registered processors one after the other and returns
    # the processed content ready to display.
    #
    # @return [String] the content processed and ready to display (it is expected to include HTML)
    def self.render(content)
      simple_format(
        Decidim.content_processors.reduce(content) do |result, type|
          renderer_klass(type).constantize.new(result).render
        end
      )
    end

    # This method overwrites the views `sanitize` method. This is required to
    # ensure the content does not include any weird HTML that could harm the end
    # user.
    #
    # @return [String] sanitized content.
    def self.sanitize(text, options = {})
      Rails::Html::WhiteListSanitizer.new.sanitize(
        text,
        { scrubber: Decidim::UserInputScrubber.new }.merge(options)
      ).try(:html_safe)
    end

    # Guess the class name of the parser for a processor
    # represented by the given symbol
    #
    # @api private
    # @return [String] the content parser class name
    def self.parser_klass(type)
      "Decidim::ContentParsers::#{type.to_s.camelize}Parser"
    end

    # Guess the class name of the renderer for a processor
    # represented by the given symbol
    #
    # @api private
    # @return [String] the content renderer class name
    def self.renderer_klass(type)
      "Decidim::ContentRenderers::#{type.to_s.camelize}Renderer"
    end
  end
end
