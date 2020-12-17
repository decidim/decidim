# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImport < Rectify::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        @data = import_data
        # parser =
        importer = Decidim::Proposals::ProposalImporter.new(form.file, Decidim::Admin::Import::Readers::Base, parser)
        importer.import

      end

      attr_reader :form

      private

      def import_data
        import_file(form.file_path, form.mime_type)
      end

      def import_file(filepath, mime_type)
        importer_for(filepath, mime_type).import do |records|
          import = TranslationImportCollection.new(
            translation_set,
            records,
            form.current_organization.available_locales
          )

          return translation_set.translations.create(import.import_attributes)
        end

        nil
      end

      def importer_for(filepath, mime_type)
        Import::ImporterFactory.build(
          filepath,
          mime_type,
          TranslationParser
        )
      end
    end
  end
end
