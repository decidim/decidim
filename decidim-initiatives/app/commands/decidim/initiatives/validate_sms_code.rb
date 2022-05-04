# frozen_string_literal: true

module Decidim
  module Initiatives
    # Command to check if sms code provided by user is valid
    class ValidateSmsCode < Decidim::Command
      # Public: Initializes the command.
      #
      # form - form containing confirmation_code.
      # verification_metadata - metadata containing the required code.
      def initialize(form, verification_metadata)
        @form = form
        @verification_metadata = verification_metadata
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everithing is valid.
      # - :invalid if verification_metadata is not present or the form code is
      #            invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless verification_metadata_valid? && valid_code?

        broadcast(:ok)
      end

      private

      def verification_metadata_valid?
        @verification_metadata && @verification_metadata["verification_code"].present?
      end

      def valid_code?
        @verification_metadata["verification_code"] == @form.verification_code
      end
    end
  end
end
