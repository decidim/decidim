# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the button to join a conference.
    class JoinConferenceButtonCell < Decidim::ViewModel
      include Decidim::LayoutHelper
      include Decidim::SanitizeHelper
      include Decidim::Conferences::Engine.routes.url_helpers

      def show
        render
      end

      private

      delegate :current_user, to: :controller, prefix: false

      def allowed?
        options[:allowed]
      end

      def shows_remaining_slots?
        options[:show_remaining_slots] && model.available_slots.positive?
      end

      def button_classes
        return "button expanded button--sc" if big_button?
        "button card__button button--sc small"
      end

      def big_button?
        options[:big_button]
      end

      def i18n_join_text
        return I18n.t("join", scope: "decidim.conferences.conference.show") if model.has_available_slots?
        I18n.t("no_slots_available", scope: "decidim.conferences.conference.show")
      end
    end
  end
end
