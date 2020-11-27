# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        # A command to confirm a previous partial offline authorization.
        class ConfirmUserOfflineAuthorization < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A form object with the verification data to confirm it.
          def initialize(form)
            @form = form
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid.
          # - :invalid if the handler wasn't valid and we couldn't proceed.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless form.valid?
            return broadcast(:invalid) unless authorization

            if confirmation_successful?
              grant_authorization
              broadcast(:ok)
            else
              broadcast(:invalid)
            end
          end

          protected

          def confirmation_successful?
            form.verification_metadata.all? do |key, value|
              authorization.verification_metadata[key] == value
            end
          end

          private

          attr_reader :form

          def grant_authorization
            Decidim.traceability.perform_action!(
              :grant_id_documents_offline_verification,
              authorization_user,
              form.current_user
            ) do
              authorization.grant!
            end
          end

          def authorization
            @authorization ||= Authorizations
                               .new(organization: form.current_organization, name: "id_documents", granted: false)
                               .query
                               .where("verification_metadata->'rejected' IS NULL")
                               .where(user: authorization_user)
                               .find { |auth| auth.verification_metadata["verification_type"] == "offline" }
          end

          def authorization_user
            @authorization_user ||= Decidim::User
                                    .where(organization: form.current_organization)
                                    .find_by(email: form.email)
          end
        end
      end
    end
  end
end
