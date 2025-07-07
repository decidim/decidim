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
      Decidim.content_processors.each_with_object(Result.new(content, {})) do |type, result|
        parse_with_processor(type, result, context)
      end
    end

    # Public: Calls the specified processors to process the given content with
    # it. For example, to convert user mentions to its Global ID representation.
    #
    # @param type [String] the name of the processor to use.
    # @param content [String] already rewritten content or regular content
    # @param context [Hash] with information to inject to the parsers as context
    #
    # @return [Result] a Result object with the content rewritten and the metadata
    def self.parse_with_processor(type, content, context)
      result = if content.is_a?(Result)
                 content
               else
                 Result.new(content, {})
               end

      if result.rewrite.is_a?(Hash)
        result.rewrite.each do |key, value|
          child_result = Result.new(value, {})
          child_result = parse_with_processor(type, child_result, context)

          result.rewrite.update(key => child_result.rewrite)
          result.metadata.update(child_result.metadata)
        end
      else
        parser = parser_klass(type).constantize.new(result.rewrite, context)
        result.rewrite = parser.rewrite
        result.metadata.update(type => parser.metadata)
      end

      result
    end

    # This calls all registered processors one after the other and returns
    # the processed content ready to display.
    #
    # @param content [String] with the content to be rendered.
    # @param wrapper_tag [String] with the HTML tag to wrap the content.
    # @param options [Hash] with options to pass to the renderer.
    #
    # @return [String] the content processed and ready to display (it is expected to include HTML)
    def self.render(content, wrapper_tag = "p", options = {})
      simple_format(
        render_without_format(content, options),
        {},
        wrapper_tag:,
        sanitize: false
      )
    end

    # This calls all registered processors one after the other and returns
    # the processed content ready to display without wrapping the content in
    # HTML.
    #
    # @param content [String] with the content to be rendered.
    # @param options [Hash] with options to pass to the renderer.
    #
    # @return [String] the content processed and ready to display.
    def self.render_without_format(content, options = {})
      return content if content.blank?

      Decidim.content_processors.reduce(content) do |result, type|
        renderer_klass(type).constantize.new(result).render(**options)
      end
    end

    # This method overwrites the views `sanitize` method. This is required to
    # ensure the content does not include any weird HTML that could harm the end
    # user.
    #
    # @return [String] sanitized content.
    def self.sanitize(text, options = {})
      Rails::Html::SafeListSanitizer.new.sanitize(
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

    module Common
      # Reports if the content being processed is in HTML format. The content
      # is interpreted as HTML when it contains one or more HTML tags in it.
      #
      # @return [Boolean] a boolean indicating if the content is HTML
      def html_content?(fragment = html_fragment)
        return false if fragment.children.count.zero?
        return true if fragment.children.count > 1

        fragment.children.first.name != "text"
      end

      # Turns the content string into a document fragment object. This is useful
      # for parsing the HTML content.
      #
      # @return [Loofah::HTML::DocumentFragment]
      def html_fragment(text = nil)
        if text
          Loofah.fragment(text)
        else
          @html_fragment ||= Loofah.fragment(content)
        end
      end
    end
  end
end
