# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImport < Rectify::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless form.parser

        import_data

        broadcast(:ok)
      end

      attr_reader :form

      private

      def import_data
        import_file(form.file_path, form.mime_type)
      end

      def import_file(filepath, mime_type)
        importer_for(filepath, mime_type).import # do |records|
        #   import = TranslationImportCollection.new(
        #     translation_set,
        #     records,
        #     form.current_organization.available_locales
        #   )

        #   return translation_set.translations.create(import.import_attributes)
        # end

        # nil
      end

      def importer_for(filepath, mime_type)
        Import::ImporterFactory.build(
          filepath,
          mime_type,
          user: current_user,
          parser: form.parser_class
        )
      end
    end
  end
end
