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
        imported_data = import_data

        importer = import_data
        imported_data = importer.import

        invalid_lines = check_invalid_lines(imported_data)
        return broadcast(:invalid_lines, invalid_lines) unless invalid_lines.empty?

        transaction do
          imported_data.each do |proposal|
            importer.finish!(proposal)
          end

          return broadcast(:ok, imported_data)
        rescue StandardError
          raise ActiveRecord::Rollback
        end

        # Something went wrong with import/finish
        broadcast(:invalid)
      end

      attr_reader :form

      private

      def import_data
        import_file(form.file_path, form.mime_type)
      end

      def import_file(filepath, mime_type)
        importer_for(filepath, mime_type)
      end

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

      def check_invalid_lines(imported_data)
        invalid_lines = []
        imported_data.each_with_index do |record, index|
          invalid_lines << index + 1 unless record.valid?
        end
        invalid_lines
      end
    end
  end
end
