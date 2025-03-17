# frozen_string_literal: true

module Decidim
  module System
    class InvitationFailedError < ActiveRecord::RecordInvalid
    end

    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.

    class CreateOrganization < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        @organization = nil
        invite_form = nil

        transaction do
          @organization = create_organization
          CreateDefaultPages.call(@organization)
          CreateDefaultHelpPages.call(@organization)
          CreateDefaultContentBlocks.call(@organization)
          invite_form = invite_user_form(@organization)
          raise InvitationFailedError if invite_form.invalid?
        end

        Decidim::InviteUser.call(invite_form) if @organization && invite_form

        broadcast(:ok)
      rescue InvitationFailedError
        broadcast(:invalid_invitation)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      private

      attr_reader :form

      def create_organization
        Decidim::Organization.create!(
          name: { form.default_locale => form.name },
          host: form.host,
          secondary_hosts: form.clean_secondary_hosts,
          reference_prefix: form.reference_prefix,
          available_locales: form.available_locales,
          available_authorizations: form.clean_available_authorizations,
          external_domain_allowlist: ["decidim.org", "github.com"],
          users_registration_mode: form.users_registration_mode,
          force_users_to_authenticate_before_access_organization: form.force_users_to_authenticate_before_access_organization,
          badges_enabled: true,
          default_locale: form.default_locale,
          omniauth_settings: form.encrypted_omniauth_settings,
          smtp_settings: form.encrypted_smtp_settings,
          send_welcome_notification: true,
          file_upload_settings: form.file_upload_settings.final,
          colors: default_colors,
          content_security_policy: form.content_security_policy
        )
      end

      def default_colors
        {
          primary: "#53bf40",
          tertiary: "#bf4053",
          secondary: "#4053bf"
        }
      end

      def invite_user_form(organization)
        Decidim::InviteUserForm.from_params(
          name: form.organization_admin_name,
          email: form.organization_admin_email,
          role: "admin",
          invitation_instructions: "organization_admin_invitation_instructions"
        ).with_context(
          current_user: form.current_user,
          current_organization: organization
        )
      end
    end
  end
end
