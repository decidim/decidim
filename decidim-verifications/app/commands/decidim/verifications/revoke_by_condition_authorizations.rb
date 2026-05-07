# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations with filter
    class RevokeByConditionAuthorizations < Decidim::Command
      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # organization - Organization object.
      # current_user - The current user.
      # form - A form object with the verification data to confirm it.
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @organization
        return broadcast(:invalid) unless @form.valid?

        if @form.before_date.present?
          RevokeByConditionAuthorizationsJob.perform_later(
            organization,
            current_user,
            @form.before_date,
            @form.impersonated_only?
          )

          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      attr_reader :organization, :form
    end
  end
end
