# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class UpdateOrganization < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(id, form)
        @organization_id = id
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

        transaction do
          save_organization
        end

        # Ensure the runtime settings are updated
        OrganizationSettings.reload(organization)

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      private

      attr_reader :form, :organization_id

      def organization
        @organization ||= Organization.find(organization_id)
      end

      def save_organization
        organization.name = form.name
        organization.host = form.host
        organization.secondary_hosts = form.clean_secondary_hosts
        organization.force_users_to_authenticate_before_access_organization = form.force_users_to_authenticate_before_access_organization
        organization.available_authorizations = form.clean_available_authorizations
        organization.users_registration_mode = form.users_registration_mode
        organization.omniauth_settings = form.encrypted_omniauth_settings
        organization.smtp_settings = form.encrypted_smtp_settings
        organization.file_upload_settings = form.file_upload_settings.final
        organization.content_security_policy = form.content_security_policy
        organization.header_snippets = form.header_snippets if Decidim.enable_html_header_snippets

        organization.save!
      end
    end
  end
end
