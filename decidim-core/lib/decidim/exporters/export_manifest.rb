# frozen_string_literal: true

module Decidim
  module Exporters
    # This class serves as a DSL to declaratively specify which artifacts are
    # exportable in a parent manifest.
    # A parent manifest is the manifest that will be used by the Serializer
    # to take the settings of the element to serialize. For example a parent
    # manifest may be a ParticipatorySpaceManifest or a ComponentManifest.
    #
    class ExportManifest
      include ActiveModel::Model
      include Virtus.model

      # A setting to choose if the collection exported by this manifest should
      # be included in the open data export available for all users.
      attribute :include_in_open_data, Boolean, default: false

      attr_reader :name, :manifest

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        space or component.
      #
      # manifest - The parent manifest where this export manifest belongs to.
      #
      def initialize(name, manifest)
        @name = name.to_sym
        @manifest = manifest
      end

      # Public: Sets the +collection block+ when a block is given, or returns
      # the previously setted +collection block+ if no block is provided.
      #
      # The +collection block+ knows how to obtain the collection of elements
      # to be serialized by the +Serializer+.
      #
      # The +collection block+ should be invoked like
      # `export.collection.call(artifact_type)` and, when evaluated,
      # will get passed an instance of the parent artifact type,
      # `Decidim::ParticipatorySpace` or `Decidim::Component` for example,
      # so you can easily find the elements to export.  It also receives, as a
      # second parameter, the user triggering the action, in case you need to
      # filter the collection based on the user.
      #
      # The +collection block+ in the end should return the collection of
      # elements to be serialized.
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

      DEFAULT_FORMATS = %w(CSV JSON Excel).freeze

      # Public: Sets the available formats if an argument is provided and
      # loads the required exporters, returns the array with the default available
      # formats otherwise.
      #
      # The formats array is used to define which exporters are available
      # in the component. Each member of the array is a string with the name
      # of the exporter class that will instantiated when needed.
      #
      # formats - The array containing the available formats.
      #
      # Returns the stored formats if previously stored, or
      # the default formats array.
      def formats(formats = nil)
        load_exporters(formats)
        @formats ||= formats || DEFAULT_FORMATS
      end

      private

      # Private: Loads the given exporters when formats argument is provided.
      #
      # formats - The array containing the formats for which to load exporters.
      #
      def load_exporters(formats)
        formats&.each { |f| require "decidim/exporters/#{f.underscore}" }
      end
    end
  end
end
