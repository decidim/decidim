# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show admin terms of service
    module AdminTermsHelper
      def admin_terms_of_service_body
        current_organization.admin_terms_of_service_body.symbolize_keys[I18n.locale].html_safe
      end

      def announcement_body
        if current_user.admin_terms_accepted?
          t("accept.success", scope: "decidim.admin.admin_terms_of_service")
        else
          t("required_review.callout", scope: "decidim.admin.admin_terms_of_service")
        end
      end

      def button_to_accept_admin_terms
        button_to(
          t("decidim.admin.admin_terms_of_service.actions.accept"),
          admin_terms_accept_path,
          class: "button button__sm button__secondary success",
          method: :put
        )
      end

      def button_to_refuse_admin_terms
        link_to(
          t("decidim.admin.admin_terms_of_service.actions.refuse"),
          decidim.root_path,
          class: "button button__sm button__secondary clear",
          data: {
            confirm: t("actions.are_you_sure", scope: "decidim.admin.admin_terms_of_service")
          }
        )
      end
    end
  end
end
