# frozen_string_literal: true

module Decidim
  module Admin
    class ImportForm < Form
      ACCEPTED_MIME_TYPES = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES

      attribute :creator, String, default: ->(form, _attribute) { form.creators.first[:creator].to_s }
      attribute :file
      attribute :user_group_id, Integer

      validates :file, presence: true
      validates :creator, presence: true
      validate :accepted_mime_type
      validate :check_invalid_lines

      def check_invalid_lines
        return if file.blank? || !accepted_mime_type

        importer.prepare
        invalid_lines = importer.invalid_lines
        errors.add(:file, I18n.t("decidim.admin.imports.invalid_lines", invalid_lines: invalid_lines.join(","))) unless invalid_lines.empty?
      end

      def file_path
        file&.path
      end

      def mime_type
        file&.content_type
      end

      def accepted_mime_type
        accepted_mime_types = ACCEPTED_MIME_TYPES.values
        return true if accepted_mime_types.include?(mime_type)
        # Avoid duplicating error messages
        return false if errors[:file].present?

        errors.add(
          :file,
          I18n.t(
            "activemodel.errors.new_import.attributes.file.invalid_mime_type",
            valid_mime_types: ACCEPTED_MIME_TYPES.keys.map do |m|
              I18n.t("decidim.admin.new_import.accepted_mime_types.#{m}")
            end.join(", ")
          )
        )
        false
      end

      def creators
        @creators ||= current_component.manifest.import_manifests.map do |manifest|
          { creator: manifest.creator, name: manifest.creator.to_s.split("::").last.downcase }
        end
      end

      def creator_class
        return creator.constantize if creator.is_a?(String)

        creator
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(
          organization: current_organization,
          id: user_group_id.to_i
        )
      end

      def importer
        @importer ||= importer_for(file_path, mime_type)
      end

      def importer_for(filepath, mime_type)
        context[:user_group] = user_group
        Import::ImporterFactory.build(
          filepath,
          mime_type,
          context: context,
          creator: creator_class
        )
      end
    end
  end
end
