# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class ParticipatoryProcessForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      translatable_attribute :subtitle, String
      translatable_attribute :description, String
      translatable_attribute :short_description, String
      translatable_attribute :meta_scope, String
      translatable_attribute :developer_group, String
      translatable_attribute :local_area, String
      translatable_attribute :target, String
      translatable_attribute :participatory_scope, String
      translatable_attribute :participatory_structure, String

      mimic :participatory_process

      attribute :end_date, Date
      attribute :slug, String
      attribute :hashtag, String
      attribute :promoted, Boolean
      attribute :scope_id, Integer
      attribute :hero_image
      attribute :banner_image

      validates :slug, presence: true
      validates :title, :subtitle, :description, :short_description, translatable_presence: true
      validates :scope_id, presence: true, if: :scope_id

      validate :slug, :slug_uniqueness

      validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
      validates :banner_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }

      def scope
        @scope ||= current_organization.scopes.where(id: scope_id).first
      end

      private

      def slug_uniqueness
        return unless current_organization.participatory_processes.where(slug: slug).where.not(id: id).any?

        errors.add(:slug, :taken)
      end
    end
  end
end
