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
          mail(to: user.email, subject: subject)
        end
      end

      private

      def add_calendar_attachment
        calendar = Icalendar::Calendar.new
        calendar.event do |event|
          event.dtstart = Icalendar::Values::DateTime.new(@meeting.start_time)
          event.dtend = Icalendar::Values::DateTime.new(@meeting.end_time)
          event.summary = present(@meeting).title
          event.description = strip_tags(present(@meeting).description)
          event.location = @meeting.address
          event.geo = [@meeting.latitude, @meeting.longitude]
          event.url = @locator.url
        end

        attachments["meeting-calendar-info.ics"] = calendar.to_ical
      end
    end
  end
end
