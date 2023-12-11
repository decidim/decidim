# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the button to cancel a meeting registation.
    class CancelRegistrationMeetingButtonCell < Decidim::ViewModel
      include Decidim::IconHelper
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

      def button_classes
        "button button__sm button__text-secondary"
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
