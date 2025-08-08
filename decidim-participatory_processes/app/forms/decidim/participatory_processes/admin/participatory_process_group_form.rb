# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process groups from the admin
      # dashboard.
      #
      class ParticipatoryProcessGroupForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        translatable_attribute :description, String
        translatable_attribute :developer_group, String
        translatable_attribute :local_area, String
        translatable_attribute :meta_scope, String
        translatable_attribute :title, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :target, String

        attribute :group_url, String
        attribute :participatory_process_ids, Array[Integer]

        attribute :promoted, Boolean

        mimic :participatory_process_group

        attribute :hero_image
        attribute :remove_hero_image, Boolean, default: false

        validates :title, :description, translatable_presence: true

        validates :hero_image, passthru: { to: Decidim::ParticipatoryProcessGroup }

        validate :group_url_format

        alias organization current_organization

        def group_url
          return if super.blank?

          return "http://#{super.strip}" unless super.match?(%r{\A(http|https)://}i)

          super.strip
        end

        private

        def group_url_format
          return if group_url.blank?

          uri = URI.parse(group_url)
          errors.add :group_url, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
        rescue URI::InvalidURIError
          errors.add :group_url, :invalid
        end
      end
    end
  end
end
