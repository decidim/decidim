# frozen_string_literal: true

module Decidim
  module Components
    # This class serves as a DSL to declarative specify which artifacts are
    # exportable in a component. It is used via the `ComponentManifest`.
    #
    class ExportManifest
      include ActiveModel::Model
      include Virtus.model

      attr_reader :name, :component_manifest

      # An setting to choose if the collection exported by this manifest should
      # be included in the open data export available for all users.
      attribute :include_in_open_data, Boolean, default: false

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        component.
      #
      # component_manifest - The parent ComponentManifest where this export
      #                      manifest belongs to.
      #
      def initialize(name, component_manifest)
        @name = name.to_sym
        @component_manifest = component_manifest
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
