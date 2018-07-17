# frozen_string_literal: true

# An example authorization handler used so that users can be verified against
# third party systems.
#
# You should probably rename this class and file to match your needs.
#
# If you need a custom form to be rendered, you can create a file matching the
# class name named "_form".
#
# Example:
#
#   A handler named Decidim::CensusHandler would look for its partial in:
#   decidim/census/form
#
# When testing your authorization handler, add this line to be sure it has a
# valid public api:
#
#   it_behaves_like "an authorization handler"
#
# See Decidim::AuthorizationHandler for more documentation.
class DummyAuthorizationHandler < Decidim::AuthorizationHandler
  # Define the attributes you need for this authorization handler. Attributes
  # are defined using Virtus.
  #
  attribute :document_number, String
  attribute :postal_code, String
  attribute :birthday, Date

  # You can (and should) also define validations on each attribute:
  #
  validates :document_number, presence: true

  # You can also define custom validations:
  #
  validate :valid_document_number

  # The only method that needs to be implemented for an authorization handler.
  # Here you can add your business logic to check if the authorization should
  # be created or not, you should return a Boolean value.
  #
  # Note that if you set some validations and overwrite this method, then the
  # validations will not run, so it's easier to remove this method and rewrite
  # your logic using ActiveModel validations.
  #
  # def valid?
  #   raise NotImplementedError
  # end

  # If set, enforces the handler to validate the uniqueness of the field
  #
  def unique_id
    document_number
  end

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  #
  def metadata
    super.merge(document_number: document_number, postal_code: postal_code)
  end

  private

  def valid_document_number
    errors.add(:document_number, :invalid) unless document_number.to_s.end_with?("X")
  end

  # If you need custom authorization logic, you can implement your own action
  # authorizer. In this case, it allows to set a list of valid postal codes for
  # an authorization.
  class DummyActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
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
