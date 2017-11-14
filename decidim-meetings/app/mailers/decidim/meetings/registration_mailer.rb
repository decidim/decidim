# frozen_string_literal: true

module Decidim
  module Meetings
    # A custom mailer for sending notifications to users when
    # they join a meeting.
    class RegistrationMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include ActionView::Helpers::SanitizeHelper

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper

      def confirmation(user, meeting)
        with_user(user) do
          @user = user
          @meeting = meeting
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
          event.summary = translated_attribute @meeting.title
          event.description = strip_tags(translated_attribute(@meeting.description))
          event.location = @meeting.address
          event.geo = [@meeting.latitude, @meeting.longitude]
          event.url = @locator.url
        end

        attachments["meeting-calendar-info.ics"] = calendar.to_ical
      end
    end
  end
end
