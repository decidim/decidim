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

    def item_name(item)
      return item[:name] unless item[:type] == "cookie" && consent_cookie_item?(item)

      Decidim.consent_cookie_name_for(request.protocol)
    end

    private

    def consent_cookie_item?(item)
      item[:name].to_s.delete_prefix("__Host-") == Decidim.consent_cookie_name.delete_prefix("__Host-")
    end
  end
end
