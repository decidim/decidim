# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to be used in the admin dashboard, including helper methods to show the Admin Terms of Use.
    module DashboardHelper
      def admin_terms_announcement_args
        {
          callout_class: "warning",
          announcement: announcement_body
        }
      end

      def announcement_body
        body = t("required_review.callout", scope: "decidim.admin.admin_terms_of_use")
        body += " "
        body += link_to(
          t("required_review.cta", scope: "decidim.admin.admin_terms_of_use"),
          admin_terms_show_path
        )
        body
      end
    end
  end
end
