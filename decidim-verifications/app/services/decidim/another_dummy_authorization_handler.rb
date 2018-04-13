# frozen_string_literal: true

module Decidim
  # An example implementation of an AuthorizationHandler to be used in tests.
  class AnotherDummyAuthorizationHandler < AuthorizationHandler
    attribute :passport_number, String

    validates :passport_number, presence: true
    validate :valid_passport_number

    def unique_id
      passport_number
    end

    private

    def valid_passport_number
      errors.add(:passport_number, :invalid) unless passport_number.start_with?("A")
    end
  end
end
