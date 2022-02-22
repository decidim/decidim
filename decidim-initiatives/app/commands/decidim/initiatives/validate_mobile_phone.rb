# frozen_string_literal: true

module Decidim
  module Initiatives
    # Command to check if mobile phone has an authorization and
    # deliver sms code
    class ValidateMobilePhone < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A MobilePhoneForm.
      # user - The user which mobile phone must be validated.
      def initialize(form, user)
        @form = form
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid. Returns the verification metadata of
      #       the form.
      # - :invalid if the user doesn't have an authorization for sms in ok
      #            status or the phone number associated with its
      #            authorization doesn't match the form number.
      def call
        return broadcast(:invalid) unless authorized? && phone_match?

        generate_code

        broadcast(:ok, @verification_metadata)
      end

      private

      def generate_code
        @verification_metadata = @form.verification_metadata
      end

      def authorizer
        return unless authorization

        Decidim::Verifications::Adapter.from_element(authorization_name).authorize(authorization, {}, nil, nil)
      end

      def authorization
        @authorization ||= Verifications::Authorizations.new(organization: @user.organization, user: @user, name: authorization_name).first
      end

      def authorization_name
        "sms"
      end

      def authorized?
        authorizer&.first == :ok
      end

      def phone_match?
        authorization.unique_id == @form.unique_id
      end
    end
  end
end
