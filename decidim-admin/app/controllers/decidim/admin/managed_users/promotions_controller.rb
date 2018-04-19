# frozen_string_literal: true

module Decidim
  module Admin
    module ManagedUsers
      # Controller that allows promoting managed users at the admin panel.
      #
      class PromotionsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/users"

        def new
          authorize! :promote, user
          @form = form(ManagedUserPromotionForm).instance
        end

        def create
          authorize! :promote, user
          @form = form(ManagedUserPromotionForm).from_params(params)

          PromoteManagedUser.call(@form, user, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("managed_users.promotion.success", scope: "decidim.admin")
              redirect_to impersonatable_users_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("managed_users.promotion.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        private

        def user
          @user ||= current_organization.users.managed.find(params[:impersonatable_user_id])
        end
      end
    end
  end
end
