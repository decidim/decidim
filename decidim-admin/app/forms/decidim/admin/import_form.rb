# frozen_string_literal: true

module Decidim
  module Admin
    class ImportForm < Form
      ACCEPTED_MIME_TYPES = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES

      attribute :current_component, Decidim::Component
      attribute :creator, Object
      attribute :file
      attribute :user_group_id, Integer

      validates :file, presence: true
      validate :accepted_mime_type

      def file_path
        file&.path
      end

      def mime_type
        file&.content_type
      end

      def accepted_mime_type
        accepted_mime_types = ACCEPTED_MIME_TYPES.values
        return if accepted_mime_types.include?(mime_type)

        errors.add(
          :file,
          I18n.t(
            "decidim.admin.new_import.attributes.file.invalid_mime_type",
            valid_mime_types: ACCEPTED_MIME_TYPES.keys.map do |m|
              I18n.t("decidim.admin.new_import.accepted_mime_types.#{m}")
            end.join(", ")
          )
        )
      end

      def creators
        current_component.manifest.import_manifests.map(&:creator)
      end

      def creator_class
        return creator.constantize if creator.is_a?(String)

        creator
      end
    end
  end
end
