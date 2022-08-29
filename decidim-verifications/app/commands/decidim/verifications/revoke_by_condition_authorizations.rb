# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations with filter
    class RevokeByConditionAuthorizations < Decidim::Command
      # Public: Initializes the command.
      #
      # organization - Organization object.
      # current_user - The current user.
      # form - A form object with the verification data to confirm it.
      def initialize(organization, current_user, form)
        @organization = organization
        @current_user = current_user
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the handler wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @organization
        return broadcast(:invalid) unless @form.valid?

        # Check before date
        if @form.before_date.present?
          authorizations_to_revoke = if @form.impersonated_only?
                                       Decidim::Verifications::AuthorizationsBeforeDate.new(
                                         organization:,
                                         date: @form.before_date,
                                         granted: true,
                                         impersonated_only: @form.impersonated_only
                                       )
                                     else
                                       Decidim::Verifications::AuthorizationsBeforeDate.new(
                                         organization:,
                                         date: @form.before_date,
                                         granted: true
                                       )
                                     end

          auths = authorizations_to_revoke.query
          auths.find_each do |auth|
            Decidim.traceability.perform_action!(
              :destroy,
              auth,
              current_user
            ) do
              auth.destroy
            end
          end

          broadcast(:ok)

        else
          broadcast(:invalid)
        end
      end

      private

      attr_reader :organization, :current_user, :form
    end
  end
end
