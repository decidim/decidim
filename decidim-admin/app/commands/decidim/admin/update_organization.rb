# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # form - A form object with the params.
      def initialize(organization, form)
        @organization = organization
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

        update_organization
        broadcast(:ok)
      end

      private

      attr_reader :form, :organization

      def update_organization
        organization.update_attributes!(attributes)
      end

      def attributes
        {
          name: form.name,
          description: form.description,
          welcome_text: form.welcome_text,
          homepage_image: form.homepage_image || organization.homepage_image,
          default_locale: form.default_locale
        }
      end
    end
  end
end
