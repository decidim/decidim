# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the button to join a meeting.
    class JoinMeetingButtonCell < Decidim::ViewModel
      include MeetingCellsHelper

      def show
        return unless model.can_be_joined_by?(current_user) || model.on_different_platform?

        render
      end

      def render_waitlist_button?
        model.waitlist_enabled? && !model.has_available_slots? && model.can_be_joined_by?(current_user) && !model.has_registration_for?(current_user)
      end

      private

      delegate :current_user, to: :controller, prefix: false

      def current_component
        model.component
      end

      def available_slots?
        @available_slots ||= model.has_available_slots?
      end

      def button_classes
        "button button__xl button__secondary w-full"
      end

      def shows_remaining_slots?
        options[:show_remaining_slots] && model.available_slots.positive?
      end

      def participant_registered_for_meeting?
        registration.present?
      end

      def i18n_join_text
        return I18n.t("join", scope: "decidim.meetings.meetings.show") if model.has_available_slots?

        I18n.t("no_slots_available", scope: "decidim.meetings.meetings.show")
      end

      def i18n_join_waitlist_text
        I18n.t("join_waitlist", scope: "decidim.meetings.meetings.show")
      end

      def i18n_confirm_text
        I18n.t("confirm", scope: "decidim.meetings.meetings.registration_confirm")
      end

      def i18n_cancel_text
        I18n.t("cancel", scope: "decidim.meetings.meetings.registration_confirm")
      end

      def registration_terms_text
        decidim_sanitize_editor translated_attribute(model.registration_terms)
      end

      def registration_form
        @registration_form ||= Decidim::Meetings::JoinMeetingForm.new
      end

      def registration_action
        @registration_action ||= model.has_available_slots? ? "registration" : "waitlist"
      end

      def registration_path
        model.has_available_slots? ? meeting_registration_path(model) : join_waitlist_meeting_registration_path(model)
      end

      def registration_translation_key
        model.has_available_slots? ? :join : :join_waitlist
      end
    end
  end
end
