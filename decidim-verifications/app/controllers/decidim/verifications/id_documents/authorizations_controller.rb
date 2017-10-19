# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      #
      # Handles verification by identity document upload
      #
      class AuthorizationsController < Decidim::ApplicationController
        helper_method :authorization

        before_action :load_authorization

        def new
          authorize! :create, @authorization

          @form = UploadForm.new
        end

        def create
          authorize! :create, @authorization

          @form = UploadForm.from_params(params.merge(user: current_user))

          PerformAuthorizationStep.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.id_documents")
              redirect_to decidim.authorizations_path
            end

            on(:invalid) do
              flash[:alert] = t("authorizations.create.error", scope: "decidim.verifications.id_documents")
              render action: :new
            end
          end
        end

        def edit
          authorize! :update, @authorization

          @form = UploadForm.from_model(@authorization)
        end

        def update
          authorize! :update, @authorization

          @form = UploadForm.from_params(
            params.merge(
              user: current_user,
              verification_attachment: @authorization.verification_attachment
            )
          )

          PerformAuthorizationStep.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.id_documents")
              redirect_to decidim.authorizations_path
            end

            on(:invalid) do
              flash[:alert] = t("authorizations.update.error", scope: "decidim.verifications.id_documents")
              render action: :edit
            end
          end
        end

        private

        def authorization
          @authorization_presenter ||= AuthorizationPresenter.new(@authorization)
        end

        def load_authorization
          @authorization = Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "id_documents"
          )
        end
      end
    end
  end
end
