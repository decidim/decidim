# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show Admin Terms of Use
    module AdminTermsHelper
      def admin_terms_announcement_args
        {
          callout_class: current_user.admin_terms_accepted? ? "" : "warning",
          announcement: t("required_review.callout", scope: "decidim.admin.admin_terms_of_use")
        }
      end

      def button_to_accept_admin_terms
        button_to(
          t("decidim.admin.admin_terms_of_use.actions.accept"),
          accept_admin_terms_of_use_path,
          class: "button success",
          method: :put
        )
      end

      def button_to_refuse_admin_terms
        button_to(
          t("decidim.admin.admin_terms_of_use.actions.refuse"),
          refuse_admin_terms_of_use_path,
          class: "button clear",
          method: :put,
          data: {
            confirm: t("actions.are_you_sure", scope: "decidim.admin.admin_terms_of_use")
          }
        )
      end
    end
  end
end
