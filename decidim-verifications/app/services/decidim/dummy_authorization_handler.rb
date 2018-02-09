# frozen_string_literal: true

module Decidim
  # An example implementation of an AuthorizationHandler to be used in tests.
  class DummyAuthorizationHandler < AuthorizationHandler
    attribute :document_number, String
    attribute :postal_code, String
    attribute :birthday, Date

    validates :document_number, presence: true
    validate :valid_document_number

    def metadata
      super.merge(document_number: document_number, postal_code: postal_code)
    end

    def unique_id
      document_number
    end

    private

    def valid_document_number
      errors.add(:document_number, :invalid) unless document_number.to_s.end_with?("X")
    end

    # An example implementation of a DefaultActionAuthorizer inherited class to override authorization status
    # checking process. In this case, it allows to set a list of valid postal codes for an authorization.
    class ActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      attr_reader :allowed_postal_codes

      # Overrides the parent class method, but it still uses it to keep the base behavior
      def authorize
        # Remove the additional setting from the options hash to avoid to be considered missing.
        @allowed_postal_codes ||= options.delete("allowed_postal_codes")

        status_code, data = *super

        if allowed_postal_codes.present?
          # Does not authorize users with different postal codes
          if status_code == :ok && !allowed_postal_codes.member?(authorization.metadata["postal_code"])
            status_code = :unauthorized
            data[:fields] = { "postal_code" => authorization.metadata["postal_code"] }
          end

          # Adds an extra message for inform the user the additional restriction for this authorization
          data[:extra_explanation] = { key: "extra_explanation",
                                       params: { scope: "decidim.verifications.dummy_authorization",
                                                 count: allowed_postal_codes.count,
                                                 postal_codes: allowed_postal_codes.join(", ") } }
        end

        [status_code, data]
      end

      # Adds the list of allowed postal codes to the redirect URL, to allow forms to inform about it
      def redirect_params
        { "postal_codes" => allowed_postal_codes&.join("-") }
      end
    end
  end
end
