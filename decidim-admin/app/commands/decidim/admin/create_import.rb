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
        importer_for(filepath, mime_type).import
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
