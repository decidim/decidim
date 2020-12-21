# frozen_string_literal: true

module Decidim
  module Importers
    class ImportManifest
      attr_reader :name # , :manifest

      def initialize(name, manifest)
        @name = name.to_sym
        @manifest = manifest
      end

      def parser(parser = nil)
        @parser ||= parser || Decidim::Admin::Import::Parser
      end

      DEFAULT_FORMATS = %w(CSV JSON Excel).freeze

      def formats
        DEFAULT_FORMATS
      end
    end
  end
end
