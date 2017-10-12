# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      #
      # Handles verification by identity document upload
      #
      class AuthorizationsController < Decidim::ApplicationController
        before_action :load_authorization

        def new
          authorize! :create, @authorization

          @form = UploadForm.new
        end

        def create
          authorize! :create, @authorization

          @form = UploadForm.from_params(params.merge(user: current_user))

          PartiallyAuthorizeUser.call(@form) do
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
        end

        private

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
