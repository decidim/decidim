# frozen_string_literal: true
module Decidim
  module System
    # A command with all the business logic when creating a new admin in
    # the system.
    class CreateAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_admin
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_admin
        Admin.create!(
          email: form.email,
          password: form.password,
          password_confirmation: form.password_confirmation
        )
      end
    end
  end
end
