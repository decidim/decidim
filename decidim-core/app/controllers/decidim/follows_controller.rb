# frozen_string_literal: true

module Decidim
  class FollowsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!
    helper_method :resource, :button_cell, :button_cell_mobile

    def destroy
      @form = form(Decidim::FollowForm).from_params(params)
      enforce_permission_to :delete, :follow, follow: @form.follow

      DeleteFollow.call(@form) do
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

      CreateFollow.call(@form) do
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
      params.require(:follow).permit(:button_classes).to_h.symbolize_keys
    end

    def button_cell_mobile
      @button_cell_mobile ||= cell("decidim/follow_button", resource, **button_options, mobile: true)
    end

    def button_cell
      @button_cell ||= cell("decidim/follow_button", resource, **button_options)
    end
  end
end
