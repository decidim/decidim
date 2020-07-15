# frozen_string_literal: true

module Decidim
  module Admin
    # The controller to handle the Admin
    # Terms of use agreement.
    class AdminTermsController < Decidim::Admin::ApplicationController
      def accept
        current_user.admin_terms_accepted_at = Time.current
        if current_user.save!
          flash[:notice] = t("accept.success", scope: "decidim.admin.admin_terms_of_use")
          redirect_to decidim_admin.root_path
        else
          flash[:alert] = t("accept.error", scope: "decidim.admin.admin_terms_of_use")
          redirect_to decidim_admin.admin_terms_show_path
        end
      end
    end
  end
end
