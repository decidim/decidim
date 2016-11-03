# frozen_string_literal: true
module Decidim
  # A n example implementation of an AuthorizationHandler to be used in tests.
  class DummyAuthorizationHandler < AuthorizationHandler
    attribute :document_number, String
    attribute :birthday, Date

    validates :document_number, presence: true

    def authorized?
      valid? && document_number.end_with?("X")
    end

    def metadata
      super.merge(document_number: document_number)
    end
  end
end
