# frozen_string_literal: true

module Decidim
  # The controller to control newsletter Opt-in for GDPR
  class NewslettersOptInController < Decidim::ApplicationController
    include FormFactory

    before_action :check_current_user_with_token

    def show
      enforce_permission_to :read, :user, current_user: current_user
      @notifications_settings = form(NotificationsSettingsForm).from_model(current_user)
    end

    def update
      enforce_permission_to :update, :user, current_user: current_user
      @notifications_settings = form(NotificationsSettingsForm).from_params(params)

      UpdateNotificationsSettings.call(current_user, @notifications_settings) do
        on(:ok) do
          current_user.newsletter_opt_in_validate
          flash[:notice] = t(".success")
          redirect_to decidim.root_path(host: current_organization)
        end

        on(:invalid) do
          flash.now[:alert] = t(".error")
          render :show
        end
      end
    end

    private

    def check_current_user_with_token
      unless current_user.newsletter_token == params[:token]
        flash[:error] = t(".unathorized")
        redirect_to decidim.root_path(host: current_organization)
      end
    end
  end
end
