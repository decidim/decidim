# frozen_string_literal: true

module Decidim
  module Conferences
    # A custom mailer for sending notifications to users when
    # they join a conference.
    class ConferenceRegistrationMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include ActionView::Helpers::SanitizeHelper

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper

      def confirmation(user, conference)
        with_user(user) do
          @user = user
          @conference = conference
          @organization = @conference.organization
          @locator = Decidim::ResourceLocatorPresenter.new(@conference)

          add_calendar_attachment

          subject = I18n.t("confirmation.subject", scope: "decidim.conferences.mailer.conference_registration_mailer")
          mail(to: user.email, subject: subject)
        end
      end

      private

      def add_calendar_attachment
        calendar = Icalendar::Calendar.new
        calendar.event do |event|
          event.dtstart = Icalendar::Values::DateTime.new(@conference.start_date)
          event.dtend = Icalendar::Values::DateTime.new(@conference.end_date)
          event.summary = translated_attribute @conference.title
          event.description = strip_tags(translated_attribute(@conference.description))
          event.url = @locator.url
        end

        attachments["conference-calendar-info.ics"] = calendar.to_ical
      end
    end
  end
end
