# frozen_string_literal: true
module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class RegisterOrganization < Rectify::Command
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

        transaction do
          organization = create_organization
          invite_admin(organization)
          CreateDefaultPages.call(organization)
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      private

      attr_reader :form

      def create_organization
        Decidim::Organization.create!(
          name: form.name,
          host: form.host,
          description: form.description,
          welcome_text: form.welcome_text,
          homepage_image: form.homepage_image,
          available_locales: form.available_locales,
          default_locale: form.default_locale
        )
      end

      def invite_admin(organization)
        Decidim::User.invite!(
          {
            name: form.organization_admin_name,
            email: form.organization_admin_email,
            organization: organization,
            roles: ["admin"]
          },
          nil,
          invitation_instructions: "organization_admin_invitation_instructions"
        )
      end
    end
  end
end
