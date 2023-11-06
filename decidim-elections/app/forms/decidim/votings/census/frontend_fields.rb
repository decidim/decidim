# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Census
      # Definition of the fields required for frontend forms
      module FrontendFields
        extend ActiveSupport::Concern

        included do
          attribute :day, Integer
          attribute :month, Integer
          attribute :year, Integer

          validates :day, :month, :year, presence: true

          validates :day, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }
          validates :month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }
          validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Time.zone.today.year }

          validate :check_birthdate
        end

        def check_birthdate
          return unless birthdate

          errors.add(:birthdate, :invalid) if Date.civil(year, month, day) > Time.zone.today
        rescue Date::Error
          errors.add(:birthdate, :invalid)
        end

        def birthdate
          return unless [year, month, day].all? { |part| part.is_a? Numeric }

          format("%04d%02d%02d", year, month, day)
        end
      end
    end
  end
end
