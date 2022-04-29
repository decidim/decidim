# frozen_string_literal: true

module Decidim
  class CookieConsentCell < Decidim::ViewModel
    def show
      render
    end

    def categories
      [
        {
          id: "cc-essential",
          title: t("layouts.decidim.cookie_consent.modal.essential.title"),
          description: t("layouts.decidim.cookie_consent.modal.essential.description"),
          mandatory: true
        },
        {
          id: "cc-preferences",
          title: t("layouts.decidim.cookie_consent.modal.preferences.title"),
          description: t("layouts.decidim.cookie_consent.modal.preferences.description")
        },
        {
          id: "cc-analytics",
          title: t("layouts.decidim.cookie_consent.modal.analytics.title"),
          description: t("layouts.decidim.cookie_consent.modal.analytics.description")
        },
        {
          id: "cc-marketing",
          title: t("layouts.decidim.cookie_consent.modal.marketing.title"),
          description: t("layouts.decidim.cookie_consent.modal.marketing.description")
        }
      ]
    end
  end
end
