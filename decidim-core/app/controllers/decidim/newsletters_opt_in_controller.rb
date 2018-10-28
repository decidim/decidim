# frozen_string_literal: true

module Decidim
  # The controller to control newsletter Opt-in for GDPR
  class NewslettersOptInController < Decidim::ApplicationController
    include FormFactory

    before_action :check_current_user_with_token

    def update
      enforce_permission_to :update, :user, current_user: current_user

      current_user.newsletter_opt_in_validate
      if current_user.save
        flash[:notice] = t(".success")
      else
        flash[:alert] = t(".error")
      end
      redirect_to decidim.root_path(host: current_organization)
    end

    private

    def check_current_user_with_token
      unless current_user.newsletter_token == params[:token]
        flash[:alert] = t("newsletters_opt_in.unathorized", scope: "decidim")
        redirect_to decidim.root_path(host: current_organization)
      end
    end
  end
end
