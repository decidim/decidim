# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class RevocationsForm < Decidim::Form
        attribute :name, String
        attribute :impersonated_only, Boolean
        attribute :before_date, Decidim::Attributes::LocalizedDate

        validates :name, presence: true
        validates :impersonated_only, inclusion: { in: [true, false] }
        validate :name_is_available
        validate :before_date_is_valid

        # The raw value tells a missing or unparseable date apart from a
        # casted nil, which would silently widen the revocation.
        def before_date=(value)
          @raw_before_date = value
          super
        end

        def option
          impersonated_only? ? "impersonated" : "total"
        end

        def period
          before_date ? "before_date" : "all"
        end

        private

        def name_is_available
          return if name.blank?

          errors.add(:name, :invalid) unless current_organization&.available_authorizations&.include?(name)
        end

        def before_date_is_valid
          return if @raw_before_date.blank?

          errors.add(:before_date, :invalid) unless before_date.is_a?(Date)
        end
      end
    end
  end
end
