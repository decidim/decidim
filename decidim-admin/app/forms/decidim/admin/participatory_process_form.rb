# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class ParticipatoryProcessForm < Rectify::Form
      mimic :participatory_process

      attribute :title, String
      attribute :subtitle, String
      attribute :slug, String
      attribute :hashtag, String
      attribute :description, String
      attribute :short_description, String

      validates :title, :slug, :subtitle, :short_description, :description, presence: true

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
