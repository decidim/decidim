# frozen_string_literal: true

module Decidim
  module System
    class ApiUserForm < Form
      mimic :admin

      attribute :name, String
      attribute :organization, ::Decidim::Organization

      validate :name, :name_uniqueness
      validates :name, presence: true
      validates :organization, presence: true

      private

      def name_uniqueness
        return unless ::Decidim::Api::ApiUser.where(name:).where(organization:).any?

        errors.add(:name, I18n.t("models.api_user.validations.name_uniqueness", scope: "decidim.system"))
      end
    end
  end
end
