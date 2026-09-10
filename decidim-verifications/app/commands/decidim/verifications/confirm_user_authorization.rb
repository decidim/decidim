# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to confirm a previous partial authorization.
    class ConfirmUserAuthorization < Decidim::Command
      # Public: Initializes the command.
      #
      # authorization - An Authorization to be confirmed.
      # form - A form object with the verification data to confirm it.
      def initialize(authorization, form)
        @authorization = authorization
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler was not valid and we could not proceed.
      # - :locked if too many failed attempts and the authorization is locked.
      #
      # Returns nothing.
      def call
        return already_confirmed! if authorization.granted?

        return invalid! unless form.valid?

        authorization.clear_expired_lock!

        return locked! if authorization.locked_for_confirmation?

        if confirmation_successful?
          valid!
        else
          invalid!
        end
      rescue StandardError => e
        invalid!(e.message)
      end

      protected

      def confirmation_successful?
        form.verification_metadata.all? do |key, value|
          authorization.verification_metadata[key] == value
        end
      end

      private

      def valid!
        authorization.grant!
        authorization.reset_failed_attempts!
        broadcast(:ok)
      end

      def invalid!(message = nil)
        authorization.record_failed_attempt!
        broadcast(:invalid, message)
      end

      def already_confirmed!
        authorization.reset_failed_attempts!
        broadcast(:already_confirmed)
      end

      def locked!
        broadcast(:locked)
      end

      attr_reader :authorization, :form
    end
  end
end
