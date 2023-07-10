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
          title: t("layouts.decidim.data_consent.modal.#{category[:slug]}.title"),
          description: t("layouts.decidim.data_consent.modal.#{category[:slug]}.description"),
          mandatory: category[:mandatory],
          items: category.has_key?(:items) ? category[:items] : []
        }
      end
    end

    def cache_hash
      hash = []
      hash << "decidim/data_consent"
      hash << Digest::MD5.hexdigest(categories.map { |category| category[:slug] }.join("-"))
      hash << current_user.try(:id).to_s
      hash << I18n.locale.to_s

      hash.join(Decidim.cache_key_separator)
    end
  end
end
