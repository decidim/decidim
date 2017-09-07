# frozen_string_literal: true

module Decidim
  module Meetings
    # A custom mailer for sending notifications to users when
    # they join a meeting.
    class RegistrationMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper

      def confirmation(user, meeting)
        with_user(user) do
          @user = user
          @meeting = meeting
          @organization = @meeting.organization

          cal = Icalendar::Calendar.new
          cal.event do |e|
            e.dtstart = Icalendar::Values::DateTime.new(@meeting.start_time)
            e.dtend = Icalendar::Values::DateTime.new(@meeting.end_time)
            e.summary = translated_attribute @meeting.title
            e.description = translated_attribute @meeting.description
            e.geo = [@meeting.latitude, @meeting.longitude]
          end

          attachments["meeting-calendar-info.ics"] = cal.to_ical

          subject = I18n.t("confirmation.subject", scope: "decidim.meetings.mailer.registration_mailer")
          mail(to: user.email, subject: subject)
        end
      end
    end
  end
end
