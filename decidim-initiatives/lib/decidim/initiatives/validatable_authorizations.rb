# frozen_string_literal: true

module Decidim
  module Initiatives
    # Concern to search for authorizations or try to create them and
    # validate their status. If the authorization cannot be created and the
    # workflow sets save_authorizations to false a new invalid authorization is
    # used. This validation is not performed if no action_authorizer class name
    # is set in the workflow.
    module ValidatableAuthorizations
      extend ActiveSupport::Concern

      included do
        validate :valid_authorization

        delegate :action_authorizer, :save_authorizations, :action_authorizer_class, to: :workflow_manifest

        def authorization_status
          return unless authorization && action_authorizer_class

          @authorization_status ||= action_authorizer_class.new(authorization, {}).authorize
        end

        def authorization
          return unless user && authorization_handler_form_class

          persisted_authorization = authorization_query.first
          @authorization ||= if persisted_authorization.present? && persisted_authorization.unique_id == authorization_handler.unique_id
                               persisted_authorization
                             elsif save_authorizations
                               create_authorization
                             else
                               new_authorization
                             end
        end

        private

        def valid_authorization
          return if authorization_status.blank?
          return if authorization_status.first == :ok

          errors.add(:base, I18n.t("invalid_authorization", scope: "decidim.initiatives.initiative_signatures.fill_personal_data"))
        end

        def create_authorization
          Decidim::Verifications::AuthorizeUser.call(authorization_handler, initiative.organization) do
            on(:transferred) do |transfer|
              self.transfer_status = transfer
            end

            on(:transfer_user) do |authorized_user|
              self.user = authorized_user
              self.transfer_status = :transfer_user
            end

            on(:invalid) do
              return Decidim::Authorization.new
            end
          end

          authorization_query.first
        end

        def authorization_query
          Verifications::Authorizations.new(**authorization_params)
        end

        def new_authorization
          Decidim::Authorization.new(created_at: Time.current, **authorization_params)
        end

        def authorization_params
          {
            organization: initiative.organization,
            user:,
            name: authorization_handler_form_class.handler_name
          }
        end
      end
    end
  end
end
