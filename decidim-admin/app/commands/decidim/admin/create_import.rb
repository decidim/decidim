# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImport < Rectify::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless form.creator

        form.context[:user_group] = user_group

        importer = importer_for(form.file_path, form.mime_type)
        imported_data = importer.prepare

        return broadcast(:invalid_lines, importer.invalid_lines) unless importer.invalid_lines.empty?

        transaction do
          importer.import!

          return broadcast(:ok, imported_data)
        rescue StandardError
          raise ActiveRecord::Rollback
        end

        # Something went wrong with import/finish
        broadcast(:invalid)
      end

      attr_reader :form

      private

      def importer_for(filepath, mime_type)
        Import::ImporterFactory.build(
          filepath,
          mime_type,
          context: form.context,
          creator: form.creator_class
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
