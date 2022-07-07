# frozen_string_literal: true

module Decidim
  module Admin
    class ImportExampleForm < Form
      attribute :name, String
      attribute :format, String

      validates :name, presence: true
      validates :format, presence: true
      validates :manifest, presence: true
      validates :reader_klass, presence: true
      validates :example_data, presence: true

      def example
        reader.example_file(example_data)
      end

      def available_formats
        Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES
      end

      private

      def manifest
        @manifest ||= current_component.manifest.import_manifests.find do |import_manifest|
          import_manifest.name.to_s == name
        end
      end

      def example_data
        return unless manifest

        manifest.example(self, current_component)
      end

      def reader
        @reader ||= reader_klass ? reader_klass.new("/dev/null") : nil
      end

      def reader_klass
        @reader_klass ||= Decidim::Admin::Import::Readers.search_by_file_extension(format)
      end
    end
  end
end
