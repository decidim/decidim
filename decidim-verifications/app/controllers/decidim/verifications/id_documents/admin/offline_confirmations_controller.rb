# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        #
        # Handles confirmations for offline verification by identity document.
        #
        class OfflineConfirmationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def new
            enforce_permission_to :update, :authorization

            @form = form(OfflineConfirmationForm).instance
          end

          def create
            enforce_permission_to :update, :authorization

            @form = form(OfflineConfirmationForm).from_params(params)

            ConfirmUserOfflineAuthorization.call(@form) do
              on(:ok) do
                flash[:notice] = t("offline_confirmations.create.success", scope: "decidim.verifications.id_documents.admin")
                redirect_to pending_authorizations_path
              end

              on(:invalid) do
                flash.now[:alert] = t("offline_confirmations.create.error", scope: "decidim.verifications.id_documents.admin")
                render action: :new
              end
            end
          end
        end
      end
    end
  end
end
