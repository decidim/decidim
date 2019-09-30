# frozen_string_literal: true

module Decidim
  module ParticipatorySpaces
    class ExportManifest
      include ActiveModel::Model
      include Virtus.model

      attr_reader :name, :participatory_space_manifest

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        component.
      #
      # participatory_space_manifest - The parent ComponentManifest where this export
      #                      manifest belongs to.
      #
      def initialize(name, participatory_space_manifest)
        @name = name.to_sym
        @participatory_space_manifest = participatory_space_manifest
      end

      # Public: Sets the collection when a block is given, or returns it if
      # no block is provided.
      #
      # The collection will get passed an instance of `Decidim::Component` when
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
