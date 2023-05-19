# frozen_string_literal: true

module Decidim
  class FollowsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :resource, :button_cell

    def destroy
      @form = form(Decidim::FollowForm).from_params(params)
      enforce_permission_to :delete, :follow, follow: @form.follow

      DeleteFollow.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("follows.destroy.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def create
      @form = form(Decidim::FollowForm).from_params(params)
      enforce_permission_to :create, :follow

      CreateFollow.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("follows.create.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def resource
      @resource ||= GlobalID::Locator.locate_signed(
        params[:follow][:followable_gid]
      )
    end

    def button_options
      # REDESIGN_PENDING - After removing the old follow button the inline
      # param should also be removed
      params.require(:follow).permit(:button_classes, :inline).to_h.symbolize_keys
    end

    def button_cell
      @button_cell ||= cell(redesign_enabled? ? "decidim/redesigned_follow_button" : "decidim/follow_button", resource, **button_options)
    end
  end
end
