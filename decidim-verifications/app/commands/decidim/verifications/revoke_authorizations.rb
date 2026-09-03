# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke granted authorizations for a verification method.
    class RevokeAuthorizations < Decidim::Command
      delegate :current_user, to: :form

      # Public: Initializes the command.
      #
      # organization - The Organization to revoke the authorizations from.
      # form - A form object with the revocation filters.
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, with the number of authorizations
      #       that will be revoked.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        count = Authorizations.new(
          organization:,
          name: form.name,
          granted: true,
          impersonated_only: form.impersonated_only,
          before_date: form.before_date
        ).query.count

        RevokeAuthorizationsJob.perform_later(organization, current_user, form.name, form.impersonated_only, form.before_date)

        broadcast(:ok, count)
      end

      private

      attr_reader :organization, :form
    end
  end
end
