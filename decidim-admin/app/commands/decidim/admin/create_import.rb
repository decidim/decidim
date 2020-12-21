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

        @imported_data = import_data
        form.context[:user_group] = user_group

        broadcast(:invalid) unless @imported_data

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
          context: form.context,
          parser: form.parser_class
        )
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(
          organization: form.context.current_organization,
          id: form.user_group_id.to_i
        )
      end
    end
  end
end
