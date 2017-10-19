# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      class AuthorizationsController < Decidim::ApplicationController
        helper_method :authorization

        before_action :load_authorization

        def new
          authorize! :create, @authorization

          @form = AddressForm.new
        end

        def create
          authorize! :create, @authorization

          @form = AddressForm.from_params(params.merge(user: current_user))

          PerformAuthorizationStep.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.postal_letter")
              redirect_to decidim.authorizations_path
            end

            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.postal_letter")
              render :new
            end
          end
        end

        def edit
          authorize! :update, @authorization

          @form = ConfirmationForm.from_params(params)
        end

        def update
          authorize! :update, @authorization

          @form = ConfirmationForm.from_params(params)

          ConfirmUserAuthorization.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.postal_letter")
              redirect_to decidim.authorizations_path
            end

            on(:invalid) do
              flash.now[:alert] = t("authorizations.update.error", scope: "decidim.verifications.postal_letter")
              render :edit
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
            name: "postal_letter"
          )
        end
      end
    end
  end
end
