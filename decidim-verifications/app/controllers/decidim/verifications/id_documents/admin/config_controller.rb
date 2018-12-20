# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        #
        # Handles the configuration for the ID documents verification
        #
        class ConfigController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def edit
            enforce_permission_to :update, :organization, organization: current_organization

            @form = form(ConfigForm).from_model(current_organization)
          end

          def update
            enforce_permission_to :update, :organization, organization: current_organization

            @form = form(ConfigForm).from_params(params)

            UpdateConfig.call(@form) do
              on(:ok) do
                flash[:notice] = t("config.update.success", scope: "decidim.verifications.id_documents.admin")
                redirect_to pending_authorizations_path
              end

              on(:invalid) do
                flash.now[:alert] = t("config.update.error", scope: "decidim.verifications.id_documents.admin")
                render action: :edit
              end
            end
          end
        end
      end
    end
  end
end
