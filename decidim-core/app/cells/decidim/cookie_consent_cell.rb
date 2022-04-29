# frozen_string_literal: true

module Decidim
  class CookieConsentCell < Decidim::ViewModel
    def show
      render
    end

    def categories
      [
        {
          id: "essential",
          title: t("layouts.decidim.cookie_consent.modal.essential.title"),
          description: t("layouts.decidim.cookie_consent.modal.essential.description"),
          mandatory: true
        },
        {
          id: "preferences",
          title: t("layouts.decidim.cookie_consent.modal.preferences.title"),
          description: t("layouts.decidim.cookie_consent.modal.preferences.description")
        },
        {
          id: "analytics",
          title: t("layouts.decidim.cookie_consent.modal.analytics.title"),
          description: t("layouts.decidim.cookie_consent.modal.analytics.description")
        },
        {
          id: "marketing",
          title: t("layouts.decidim.cookie_consent.modal.marketing.title"),
          description: t("layouts.decidim.cookie_consent.modal.marketing.description")
        }
      ]
    end
  end
end
