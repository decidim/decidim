# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class RevocationsForm < Decidim::Form
        attribute :name, String
        attribute :impersonated_only, Boolean, default: false
        attribute :before_date, Decidim::Attributes::LocalizedDate

        validates :name, presence: true
        validate :name_is_available

        private

        def name_is_available
          return if name.blank?

          errors.add(:name, :invalid) unless current_organization&.available_authorizations&.include?(name)
        end
      end
    end
  end
end
