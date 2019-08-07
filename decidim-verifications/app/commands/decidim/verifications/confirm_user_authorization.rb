# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to confirm a previous partial authorization.
    class ConfirmUserAuthorization < Rectify::Command
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
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:already_confirmed) if authorization.granted?

        return broadcast(:invalid) unless form.valid?

        if confirmation_successful?
          authorization.grant!

          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      protected

      def confirmation_successful?
        form.verification_metadata.all? do |key, value|
          authorization.verification_metadata[key] == value
        end
      end

      private

      attr_reader :authorization, :form
    end
  end
end
