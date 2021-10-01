# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the media link card for an instance of a RegistrationType
    class RegistrationTypeCell < Decidim::ViewModel
      include ActionView::Helpers::NumberHelper
      include Decidim::SanitizeHelper
      include Decidim::Conferences::Engine.routes.url_helpers
      include Decidim::LayoutHelper

      def show
        render
      end

      private

      delegate :current_user, to: :controller, prefix: false

      def title
        decidim_sanitize translated_attribute model.title
      end

      def description
        decidim_sanitize_editor translated_attribute model.description
      end

      def price
        return I18n.t("free", scope: "decidim.conferences.conference.show") if model.price.blank?

        number_to_currency(model.price, locale: I18n.locale, unit: Decidim.currency_unit)
      end

      def allowed?
        options[:allowed]
      end

      def button_classes
        "button button--sc small"
      end

      def conference
        model.conference
      end

      def i18n_join_text
        return I18n.t("registration", scope: "decidim.conferences.conference.show") if conference.has_available_slots?

        I18n.t("no_slots_available", scope: "decidim.conferences.conference.show")
      end
    end
  end
end
