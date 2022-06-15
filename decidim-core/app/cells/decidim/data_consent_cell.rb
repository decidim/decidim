# frozen_string_literal: true

module Decidim
  class DataConsentCell < Decidim::ViewModel
    def show
      render
    end

    def categories
      @categories ||= Decidim.consent_categories.map do |category|
        {
          slug: category[:slug],
          title: t("layouts.decidim.cookie_consent.modal.#{category[:slug]}.title"),
          description: t("layouts.decidim.cookie_consent.modal.#{category[:slug]}.description"),
          mandatory: category[:mandatory],
          cookies: category.has_key?(:cookies) ? category[:cookies] : []
        }
      end
    end
  end
end
