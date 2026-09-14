# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Activates the authenticator app once the user proves it shows the right code.
    class ConfirmTotp < EnrollAuthenticator
      # Public: Initializes the command.
      #
      # authenticator - The pending authenticator being confirmed.
      # form - A form object with the code typed by the user.
      def initialize(authenticator, form)
        super(authenticator&.user)
        @form = form
        @authenticator = authenticator
      end

      protected

      def invalid? = authenticator.blank? || authenticator.confirmed? || form.invalid? || !authenticator.verify(form)

      def enroll = authenticator.update!(confirmed_at: Time.current)

      private

      attr_reader :form, :authenticator
    end
  end
end
