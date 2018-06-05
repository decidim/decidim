# frozen_string_literal: true

module Decidim
  # The controller to handle the current user's
  # Terms and Conditions agreement.
  class TosController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def accept_tos
      current_user.accepted_tos_version = Time.current
      if current_user.save!
        flash[:notice] = t("accept.success", scope: "decidim.pages.terms_and_conditions")
        redirect_to after_sign_in_path_for current_user
      else
        flash[:alert] = t("accept.error", scope: "decidim.pages.terms_and_conditions")
        redirect_to decidim.page_path tos_page
      end
    end
  end
end
