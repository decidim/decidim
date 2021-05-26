# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show Admin Terms of Use
    module AdminTermsHelper
      def admin_terms_of_use_body
        current_organization.admin_terms_of_use_body.symbolize_keys[I18n.locale].html_safe
      end

      def announcement_body
        if current_user.admin_terms_accepted?
          t("accept.success", scope: "decidim.admin.admin_terms_of_use")
        else
          t("required_review.callout", scope: "decidim.admin.admin_terms_of_use")
        end
      end

      def button_to_accept_admin_terms
        button_to(
          t("decidim.admin.admin_terms_of_use.actions.accept"),
          admin_terms_accept_path,
          class: "button success",
          method: :put
        )
      end

      def button_to_refuse_admin_terms
        link_to(
          t("decidim.admin.admin_terms_of_use.actions.refuse"),
          decidim.root_path,
          class: "button clear",
          data: {
            confirm: t("actions.are_you_sure", scope: "decidim.admin.admin_terms_of_use")
          }
        )
      end
    end
  end
end
