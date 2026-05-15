# frozen_string_literal: true

require "rqrcode"

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
          @registration_code_enabled = meeting.component.settings.registration_code_enabled
          @qr_filename = "qr-#{@registration.code.parameterize}.png"

          add_calendar_attachment
          add_qr_code_attachment if @registration_code_enabled

          subject = I18n.t("confirmation.subject", scope: "decidim.meetings.mailer.registration_mailer")
          mail(to: user.email, subject:)
        end
      end

      private

      def qr_code
        @qr_code ||= RQRCode::QRCode.new(@registration.validation_code_short_link.short_url)
      end

      def add_calendar_attachment
        calendar = Icalendar::Calendar.new
        calendar.add_event(Calendar::MeetingToEvent.new(@meeting).event)

        attachments["meeting-calendar-info.ics"] = calendar.to_ical
      end

      def add_qr_code_attachment
        attachments[@qr_filename] = qr_code.as_png(size: 500).to_blob
      end
    end
  end
end
