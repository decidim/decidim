# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to revoke authorizations with filter
    class RevokeByConditionAuthorizations < Rectify::Command
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
        return broadcast(:invalid) unless @form.valid?

        # Date format
        before_date = @form.before_date_picker.strftime("%d/%m/%Y")
        # Check before date
        if before_date.present?

          # Check if before_date, then filter it
          authorizations_to_revoke = if @form.impersonated_only == true
                                       Decidim::Verifications::AuthorizationsBeforeDate.new(
                                         organization: organization,
                                         date: before_date,
                                         granted: true,
                                         impersonated_only: @form.impersonated_only
                                       )
                                     else
                                       Decidim::Verifications::AuthorizationsBeforeDate.new(
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

      attr_reader :organization, :current_user, :form
    end
  end
end
