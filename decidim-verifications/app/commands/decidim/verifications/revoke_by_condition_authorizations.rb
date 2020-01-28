# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations with filter
    class RevokeByConditionAuthorizations < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - Organization object.
      # current_user - The current user.
      # before_date - The filter date.
      # impersonated_only - Boolean that defines granted or not (optional)
      def initialize(organization, current_user, before_date, impersonated_only)
        @organization = organization
        @current_user = current_user
        @before_date = before_date
        @impersonated_only = impersonated_only
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        # Check before date
        if before_date.present?

          # Check if before_date, then filter it
          if impersonated_only == true
            authorizations_to_revoke = Decidim::Verifications::AuthorizationsBeforeDate.new(
              organization: organization,
              date: before_date,
              granted: true,
              impersonated_only: impersonated_only
            )
          else
            authorizations_to_revoke = Decidim::Verifications::AuthorizationsBeforeDate.new(
              organization: organization,
              date: before_date,
              granted: true
            )
          end

          auths_arr = authorizations_to_revoke.query.to_a
          auths_arr.each do |auth|
            Decidim.traceability.perform_action!(
              :delete,
              auth,
              current_user
            ) do
              auth.delete
            end
          end

          broadcast(:ok)

        else
          broadcast(:invalid)
        end
      rescue StandardError => e
        broadcast(:invalid, e.message)
      end

      private

      attr_reader :organization, :current_user, :before_date, :impersonated_only
    end
  end
end
