# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to confirm a previous partial authorization.
    class ConfirmUserAuthorization < Rectify::Command
      # Number of failed confirmation attempts before throttling.
      MAX_FAILED_ATTEMPTS = 2

      # Public: Initializes the command.
      #
      # authorization - An Authorization to be confirmed.
      # form - A form object with the verification data to confirm it.
      def initialize(authorization, form, session)
        @authorization = authorization
        @form = form
        @session = session
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return already_confirmed! if authorization.granted?

        return invalid! unless form.valid?

        throttle! if too_many_failed_attempts?

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
        reset_failed_attempts!
        broadcast(:ok)
      end

      def invalid!(message = nil)
        record_failed_attempt!
        broadcast(:invalid, message)
      end

      def already_confirmed!
        reset_failed_attempts!
        broadcast(:already_confirmed)
      end

      def too_many_failed_attempts?
        failed_attempts > MAX_FAILED_ATTEMPTS
      end

      def failed_attempts
        session[:failed_attempts] ||= 0
      end

      def reset_failed_attempts!
        session[:failed_attempts] = 0
      end

      def record_failed_attempt!
        session[:failed_attempts] = failed_attempts + 1
      end

      def throttle!
        sleep rand * failed_attempts
      end

      attr_reader :authorization, :form, :session
    end
  end
end
