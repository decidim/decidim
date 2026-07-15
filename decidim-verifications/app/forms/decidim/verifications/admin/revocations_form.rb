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
        validate :impersonated_only_is_present
        validate :before_date_is_valid

        # Raw values tell missing or unparseable params apart from casted
        # defaults, which would silently widen the revocation.
        def impersonated_only=(value)
          @raw_impersonated_only = value
          super
        end

        def before_date=(value)
          @raw_before_date = value
          super
        end

        private

        def name_is_available
          return if name.blank?

          errors.add(:name, :invalid) unless current_organization&.available_authorizations&.include?(name)
        end

        def impersonated_only_is_present
          errors.add(:impersonated_only, :blank) if @raw_impersonated_only.nil?
        end

        def before_date_is_valid
          return if @raw_before_date.blank?

          errors.add(:before_date, :invalid) unless before_date.is_a?(Date)
        end
      end
    end
  end
end
