# frozen_string_literal: true

module Decidim
  module Importers
    # For importing data from files to components. Every resource type should
    # specify it's own creator, which will be responsible for producing (creating)
    # and finishing (saving) the imported resource.
    class ImportManifest
      attr_reader :name, :manifest

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        space or component.
      #
      # manifest - The parent manifest where this import manifest belongs to.
      #
      def initialize(name, manifest)
        @name = name.to_sym
        @manifest = manifest
      end

      # Public: Sets the creator when an argument is provided, returns the
      # stored creator otherwise.
      def creator(creator = nil)
        @creator ||= creator || Decidim::Admin::Import::Creator
      end

      DEFAULT_FORMATS = %w(CSV JSON Excel).freeze

      def formats
        DEFAULT_FORMATS
      end
    end
  end
end
