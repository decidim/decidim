# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when unofficializing a user.
    class UnofficializeUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form - The unofficialization form.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when the unofficialization suceeds.
      # - :invalid when the form is invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        unofficialize_user

        broadcast(:ok)
      end

      private

      attr_reader :form

      def unofficialize_user
        form.user.update!(officialized_at: nil, officialized_as: nil)
      end
    end
  end
end
