# frozen_string_literal: true

module Decidim
  class FollowsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :resource

    def destroy
      @form = form(Decidim::FollowForm).from_params(params)
      authorize! :delete, @form.follow

      DeleteFollow.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("follows.destroy.error", scope: "decidim") }, status: 422
        end
      end
    end

    def create
      @form = form(Decidim::FollowForm).from_params(params)
      authorize! :create, Follow

      CreateFollow.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("follows.create.error", scope: "decidim") }, status: 422
        end
      end
    end

    def resource
      @resource ||= GlobalID::Locator.locate_signed(
        params[:follow][:followable_gid]
      )
    end
  end
end
