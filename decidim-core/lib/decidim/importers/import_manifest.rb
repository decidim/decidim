# frozen_string_literal: true

module Decidim
  module Importers
    class ImportManifest
      attr_reader :name #, :manifest

      def initialize(name, manifest)
        @name = name.to_sym
        @manifest = manifest
      end

      def importer(importer = nil)
        @importer ||= importer || Decidim::Importers::Importer
      end

      DEFAULT_FORMATS = %w(CSV).freeze

      def formats
        DEFAULT_FORMATS
      end
    end
  end
end
