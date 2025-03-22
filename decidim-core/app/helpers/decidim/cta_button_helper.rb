# frozen_string_literal: true

module Decidim
  # A Helper to render the Call To Action button.
  module CtaButtonHelper
    # Renders the Call To Action button. Link and text can be configured
    # per organization.
    def cta_button_text
      translated_attribute(current_organization.cta_button_text).presence || t("decidim.pages.home.hero.participate")
    end

    def cta_button
      link_to cta_button_text, cta_button_path, class: "hero-cta button expanded large button--sc", title: t("decidim.pages.home.hero.participate_title")
    end

    # Finds the CTA button path to reuse it in other places.
    def cta_button_path
      if current_organization.cta_button_path.present?
        "/#{current_organization.cta_button_path}"
      elsif Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?
        decidim_participatory_processes.participatory_processes_path(locale: current_locale)
      elsif current_user
        decidim.account_path
      elsif current_organization.sign_up_enabled?
        decidim.new_user_registration_path
      else
        decidim.new_user_session_path
      end
    end
  end
end
