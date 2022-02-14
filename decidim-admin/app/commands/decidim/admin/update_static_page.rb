# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a static page.
    class UpdateStaticPage < Decidim::Command
      # Public: Initializes the command.
      #
      # page - The StaticPage to update
      # form - A form object with the params.
      def initialize(page, form)
        @page = page
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

        update_page
        update_organization_tos_version if form.changed_notably
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_page
        Decidim.traceability.update!(
          @page,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
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
