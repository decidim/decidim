# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static page.
    class CreateStaticPage < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
        @page = nil
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_page
        update_organization_tos_version
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_page
        @page = Decidim.traceability.create!(
          StaticPage,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          organization: form.organization,
          title: form.title,
          slug: form.slug,
          show_in_footer: form.show_in_footer,
          weight: form.weight,
          topic: form.topic,
          content: form.content,
          allow_public_access: form.allow_public_access
        }
      end

      def update_organization_tos_version
        UpdateOrganizationTosVersion.call(@form.organization, @page, @form)
      end
    end
  end
end
