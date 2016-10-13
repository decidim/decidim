# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class ParticipatoryProcessForm < Rectify::Form
      include TranslatableAttributes

      translatable_attribute :title, String
      translatable_attribute :subtitle, String
      translatable_attribute :description, String
      translatable_attribute :short_description, String

      mimic :participatory_process

      attribute :slug, String
      attribute :hashtag, String
      attribute :promoted, Boolean
      attribute :hero_image
      attribute :banner_image

      validates :slug, presence: true
      translatable_validates :title, :subtitle, :description, :short_description, presence: true

      validate :slug, :slug_uniqueness

      private

      def slug_uniqueness
        return unless ParticipatoryProcess.where(slug: slug).where.not(id: id).any?

        errors.add(
          :slug,
          I18n.t("models.participatory_process.validations.slug_uniqueness", scope: "decidim.admin")
        )
      end
    end
  end
end
