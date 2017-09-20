# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A custom mailer for sending an invitation to join a meeting to
      # an existing user.
      class InviteJoinMeetingMailer < Decidim::ApplicationMailer
        include Decidim::TranslationsHelper
        include ActionView::Helpers::SanitizeHelper

        helper Decidim::ResourceHelper
        helper Decidim::TranslationsHelper

        def invite(user, meeting)
          with_user(user) do
            @user = user
            @meeting = meeting
            @organization = @meeting.organization
            @locator = Decidim::ResourceLocatorPresenter.new(@meeting)

            subject = I18n.t("invite.subject", scope: "decidim.meetings.mailer.invite_join_meeting_mailer")
            mail(to: user.email, subject: subject)
          end
        end
      end
    end
  end
end
