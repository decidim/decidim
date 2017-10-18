# frozen_string_literal: true

module Decidim
  # A Helper to render homepage elements.
  module HomepageHelper
    # Renders the Call To Action button. Link and text can be configured
    # per organizationn.
    def cta_button
      button_text = translated_attribute(current_organization.cta_button_text).presence || t("pages.home.hero.participate")
      button_path =
        current_organization.cta_button_path.presence || decidim_participatory_processes.participatory_processes_path

      link_to button_text, button_path, class: "hero-cta button expanded large button--sc"
    end
  end
end
