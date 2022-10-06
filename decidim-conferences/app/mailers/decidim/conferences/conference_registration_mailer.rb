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
      helper Decidim::ApplicationHelper

      def pending_validation(user, conference, registration_type)
        with_user(user) do
          @user = user
          @conference = conference
          @organization = @conference.organization
          @locator = Decidim::ResourceLocatorPresenter.new(@conference)
          @registration_type = registration_type

          subject = I18n.t("pending_validation.subject", scope: "decidim.conferences.mailer.conference_registration_mailer")
          mail(to: user.email, subject:)
        end
      end

      def confirmation(user, conference, registration_type)
        with_user(user) do
          @user = user
          @conference = conference
          @organization = @conference.organization
          @locator = Decidim::ResourceLocatorPresenter.new(@conference)
          @registration_type = registration_type

          add_calendar_attachment

          subject = I18n.t("confirmation.subject", scope: "decidim.conferences.mailer.conference_registration_mailer")
          mail(to: user.email, subject:)
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
