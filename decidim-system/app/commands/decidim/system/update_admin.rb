# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic when updating an admin in
    # the system.
    class UpdateAdmin < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(admin, form)
        @admin = admin
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_admin
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_admin
        @admin.update!(attributes)
      end

      def attributes
        {
          email: form.email
        }.merge(password_attributes)
      end

      def password_attributes
        return {} if form.password == form.password_confirmation && form.password.blank?

        {
          password: form.password,
          password_confirmation: form.password_confirmation
        }
      end
    end
  end
end
