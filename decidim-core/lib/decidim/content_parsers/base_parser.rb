# frozen_string_literal: true

module Decidim
  module ContentParsers
    # Abstract base class for content parsers, so they have the same contract
    #
    # @example How to use a content parser class
    #   parser = Decidim::ContentParsers::CustomParser.new(content, context)
    #   parser.rewrite # returns the content rewritten
    #   parser.metadata # returns a Metadata object
    #
    # @abstract Subclass and override {#rewrite} and {#metadata} to implement a content parser
    class BaseParser
      # Class used as a container for metadata
      Metadata = Class.new

      # @return [String] the content to be rewritten
      attr_reader :content

      # @return [Hash] with context information
      attr_reader :context

      # Gets initialized with the `content` to parse
      #
      # @param content [String] already rewritten content or regular content
      # @param context [Hash] arbitrary information to have a context
      def initialize(content, context)
        @content = content || ""
        @context = context
      end

      # Parse the `content` and return it modified
      #
      # @example Implementation for search and mark prohibited words
      #   def rewrite
      #     content.gsub('foo', '~~foo~~')
      #   end
      #
      # @abstract Subclass is expected to implement it
      # @return [String] the content rewritten
      def rewrite
        content
      end

      # Collects and returns metadata. This metadata is accessible at parsing time
      # so it can be acted upon (sending emails to the users) or maybe even stored
      # at the DB for later consultation.
      #
      # @example Implementation for return a counter of prohibited words found
      #   Metadata = Struct.new(:count)
      #
      #   def metadata
      #     Metadata.new(content.scan('foo').size)
      #   end
      #
      # @abstract Subclass is expected to implement it
      # @return [Metadata] a Metadata object that holds extra information
      def metadata
        Metadata.new
      end
    end
  end
end
