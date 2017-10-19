# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        #
        # Handles confirmations for verification by identity document upload.
        #
        class ConfirmationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          before_action :load_pending_authorization

          def new
            authorize! :update, @pending_authorization

            @form = InformationForm.new
          end

          def create
            authorize! :update, @pending_authorization

            @form = InformationForm.from_params(params)

            ConfirmUserAuthorization.call(@pending_authorization, @form) do
              on(:ok) do
                flash[:notice] = t("confirmations.create.success", scope: "decidim.verifications.id_documents.admin")
                redirect_to pending_authorizations_path
              end

              on(:invalid) do
                flash.now[:alert] = t("confirmations.create.error", scope: "decidim.verifications.id_documents.admin")
                render action: :new
              end
            end
          end

          private

          def load_pending_authorization
            @pending_authorization = Authorization.find(params[:pending_authorization_id])
          end
        end
      end
    end
  end
end
