# frozen_string_literal: true

module Decidim
  module Features
    # This class serves as a DSL to declarative specify which artifacts are
    # exportable in a feature. It is used via the `FeatureManifest`.
    #
    class ExportManifest
      attr_reader :name

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        feature.
      #
      def initialize(name)
        @name = name.to_sym
      end

      # Public: Sets the collection when a block is given, or returns it if
      # no block is provided.
      #
      # The collection will get passed an instance of `Decidim::Feature` when
      # it's evaluated so you can easily find the elements to export.
      #
      # &block - An optional block that returns the collection once evaluated.
      #
      # Returns the stored collection.
      def collection(&block)
        if block_given?
          @collection = block
        else
          @collection
        end
      end

      # Public: Sets the serializer when an argument is provided, returns the
      # stored serializer otherwise.
      #
      # A `Serializer` will be run against each and every element of the collection
      # in order to extract and process the relevant fields.
      #
      # serializer - A subclass of `Decidim::Exporters::Serializer`.
      #
      # Returns the stored serializer if previously stored, or
      # `Decidim::Exporters::Serializer` as a default implementation.
      def serializer(serializer = nil)
        @serializer ||= serializer || Decidim::Exporters::Serializer
      end
    end
  end
end
