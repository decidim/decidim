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
          @organization = create_organization
          CreateDefaultPages.call(@organization)
          invite_form = invite_user_form(@organization)
          return broadcast(:invalid) if invite_form.invalid?
          Decidim::InviteUser.call(invite_form)
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
          secondary_hosts: form.clean_secondary_hosts,
          reference_prefix: form.reference_prefix,
          available_locales: form.available_locales,
          available_authorizations: form.clean_available_authorizations,
          default_locale: form.default_locale
        )
      end

      def invite_user_form(organization)
        Decidim::InviteAdminForm.from_params(
          name: form.organization_admin_name,
          email: form.organization_admin_email,
          roles: %w(admin),
          invitation_instructions: "organization_admin_invitation_instructions"
        ).with_context(
          current_user: form.current_user,
          current_organization: organization
        )
      end
    end
  end
end
