# frozen_string_literal: true
module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class UpdateOrganization < Rectify::Command
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
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          save_organization
        end

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
        byebug
        organization.name = form.name
        organization.host = form.host
        organization.secondary_hosts = form.clean_secondary_hosts
        organization.available_authorizations = form.clean_available_authorizations

        organization.save!
      end
    end
  end
end
