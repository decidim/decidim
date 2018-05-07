# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the button to join a meeting.
    class JoinMeetingButtonCell < Decidim::Meetings::ViewModel
      def show
        render
      end

      private

      delegate :current_user, :current_component, to: :controller, prefix: false

      def i18n_scope
        "decidim.meetings.meetings.show"
      end

      def button_classes
        return "button expanded button--sc" if big_button?
        "button card__button button--sc small"
      end

      def big_button?
        options[:big_button]
      end
    end
  end
end
