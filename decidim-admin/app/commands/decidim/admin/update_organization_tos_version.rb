# frozen_string_literal: true

module Decidim
  module Admin
    # A command with the business logic for updating the current
    # organization tos_version attribute.
    class UpdateOrganizationTosVersion < Decidim::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # page - A static_page instance (slug = "terms-of-service").
      # form - A form object with the params.
      def initialize(organization, page, form)
        @organization = organization
        @page = page
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid or not the TOS page.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.nil?
        return broadcast(:invalid) if @page.nil?
        return broadcast(:invalid) unless @page.slug == "terms-of-service"

        update_organization_tos_version
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_organization_tos_version
        Decidim.traceability.update!(
          @organization,
          @form.current_user,
          tos_version: @page.updated_at
        )
      end
    end
  end
end
