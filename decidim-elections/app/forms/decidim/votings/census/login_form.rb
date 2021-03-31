# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # This class holds the data to login with census data
      class LoginForm < Decidim::Form
        include Decidim::Votings::Census::OnlineFields

        attribute :day, Integer
        attribute :month, Integer
        attribute :year, Integer

        validates :day, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }
        validates :month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }
        validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.today.year }

        validate :check_birthdate

        def check_birthdate
          errors.add(:birthdate, :invalid) if Date.civil(year, month, day) > Date.today
        rescue Date::Error
          errors.add(:birthdate, :invalid)
        end

        def birthdate
          return unless year && month && day

          "%04d%02d%02d" % [year, month, day]
        end

        def document_types_for_select
          DOCUMENT_TYPES.map do |document_type|
            [
              I18n.t(document_type.downcase, scope: "decidim.votings.census.document_types"),
              document_type
            ]
          end
        end
      end
    end
  end
end
