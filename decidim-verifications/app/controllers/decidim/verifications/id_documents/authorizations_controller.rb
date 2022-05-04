# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      #
      # Handles verification by identity document upload
      #
      class AuthorizationsController < ApplicationController
        include Decidim::Verifications::Renewable

        helper_method :authorization, :verification_type, :using_offline?, :using_online?, :available_methods

        before_action :load_authorization

        def choose
          return redirect_to action: :new, using: verification_type if available_methods.count == 1

          render :choose
        end

        def new
          raise ActionController::RoutingError, "Method not available" unless available_methods.include?(verification_type)

          enforce_permission_to :create, :authorization, authorization: @authorization

          @form = UploadForm.from_params(id_document_upload: { verification_type: verification_type })
        end

        def create
          enforce_permission_to :create, :authorization, authorization: @authorization

          @form = UploadForm.from_params(params.merge(user: current_user)).with_context(current_organization: current_organization)

          PerformAuthorizationStep.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.id_documents")
              redirect_to decidim_verifications.authorizations_path
            end

            on(:invalid) do
              flash[:alert] = t("authorizations.create.error", scope: "decidim.verifications.id_documents")
              render action: :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :authorization, authorization: @authorization

          @form = UploadForm.from_model(@authorization)
        end

        def update
          enforce_permission_to :update, :authorization, authorization: @authorization

          @form = UploadForm.from_params(
            params.merge(
              user: current_user,
              verification_type: verification_type,
              verification_attachment: params[:id_document_upload][:verification_attachment] || @authorization.verification_attachment.blob
            )
          ).with_context(current_organization: current_organization)

          PerformAuthorizationStep.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.id_documents")
              redirect_to decidim_verifications.authorizations_path
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

        def verification_type
          params[:using] || authorization_verification_type || available_methods.first
        end

        def authorization_verification_type
          return unless @authorization

          @authorization.verification_metadata["verification_type"]
        end

        def using_online?
          verification_type == "online"
        end

        def using_offline?
          verification_type == "offline"
        end

        def available_methods
          @available_methods ||= current_organization.id_documents_methods
        end
      end
    end
  end
end
