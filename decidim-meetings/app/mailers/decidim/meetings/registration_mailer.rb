# frozen_string_literal: true

module Decidim
  module Meetings
    # A custom mailer for sending notifications to users when
    # they join a meeting.
    class RegistrationMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include ActionView::Helpers::SanitizeHelper
      include Decidim::ApplicationHelper

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper
      helper Decidim::ApplicationHelper

      def confirmation(user, meeting, registration)
        with_user(user) do
          @user = user
          @meeting = meeting
          @registration = registration
          @organization = @meeting.organization
          @locator = Decidim::ResourceLocatorPresenter.new(@meeting)

          add_calendar_attachment

          subject = I18n.t("confirmation.subject", scope: "decidim.meetings.mailer.registration_mailer")
          mail(to: user.email, subject:)
        end
      end

      private

      def add_calendar_attachment
        calendar = Icalendar::Calendar.new
        calendar.add_event(Calendar::MeetingToEvent.new(@meeting).event)

        attachments["meeting-calendar-info.ics"] = calendar.to_ical
      end
    end
  end
end
