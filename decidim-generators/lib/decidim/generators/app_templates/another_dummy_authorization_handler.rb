# frozen_string_literal: true

# An example implementation of an AuthorizationHandler to be used in tests.
class AnotherDummyAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :passport_number, String
  attribute :postal_code, String

  validates :passport_number, presence: true
  validate :valid_passport_number

  def metadata
    super.merge(passport_number:, postal_code:)
  end

  def unique_id
    passport_number
  end

  private

  def valid_passport_number
    errors.add(:passport_number, :invalid) unless passport_number.to_s.start_with?("A")
  end
end
