# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the button to join a meeting.
    class JoinMeetingButtonCell < Decidim::ViewModel
      include MeetingCellsHelper
      include Decidim::SanitizeHelper
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::FormOptionsHelper

      def show
        render
      end

      private

      delegate :current_user, to: :controller, prefix: false

      def current_component
        model.component
      end

      def button_classes
        return "button expanded button--sc" if big_button?

        "button card__button button--sc small"
      end

      def big_button?
        options[:big_button]
      end

      def shows_remaining_slots?
        options[:show_remaining_slots] && model.available_slots.positive?
      end

      def i18n_join_text
        return I18n.t("join", scope: "decidim.meetings.meetings.show") if model.has_available_slots?

        I18n.t("no_slots_available", scope: "decidim.meetings.meetings.show")
      end

      def i18n_confirm_text
        I18n.t("confirm", scope: "decidim.meetings.meetings.registration_confirm")
      end

      def i18n_cancel_text
        I18n.t("cancel", scope: "decidim.meetings.meetings.registration_confirm")
      end

      def registration_terms_text
        decidim_sanitize translated_attribute(model.registration_terms)
      end

      def registration_form
        @registration_form ||= Decidim::Meetings::JoinMeetingForm.new
      end
    end
  end
end
