# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the button to cancel a meeting registration.
    class CancelRegistrationMeetingButtonCell < Decidim::ViewModel
      include MeetingCellsHelper

      def show
        return unless model.can_be_joined_by?(current_user)
        return unless model.has_registration_for?(current_user)

        render
      end

      private

      def current_component
        model.component
      end

      def registration_status
        model.registrations.find_by(user: current_user)&.status
      end

      def action_keys
        if registration_status == "waiting_list"
          {
            button: "leave_waitlist",
            modal_title: "leave_waitlist",
            modal_confirmation: "leave_waitlist_confirmation"
          }
        else
          {
            button: "leave",
            modal_title: "leave",
            modal_confirmation: "leave_confirmation"
          }
        end
      end

      def cancel_button_text
        I18n.t(action_keys[:button], scope: "decidim.meetings.meetings.show")
      end

      def i18n_modal_title
        I18n.t(action_keys[:modal_title], scope: "decidim.meetings.meetings.show")
      end

      def i18n_modal_confirmation_text
        I18n.t(action_keys[:modal_confirmation], scope: "decidim.meetings.meetings.show")
      end

      def button_classes
        "button button__sm button__transparent-secondary w-full"
      end

      def icon_name
        "calendar-close-line"
      end

      def registration_form
        @registration_form ||= Decidim::Meetings::JoinMeetingForm.new
      end
    end
  end
end
