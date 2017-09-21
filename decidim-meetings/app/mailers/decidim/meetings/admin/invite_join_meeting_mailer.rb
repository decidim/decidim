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

        helper_method :routes

        def invite(user, meeting, invited_by)
          with_user(user) do
            @user = user
            @meeting = meeting
            @invited_by = invited_by
            @organization = @meeting.organization
            @locator = Decidim::ResourceLocatorPresenter.new(@meeting)

            subject = I18n.t("invite.subject", scope: "decidim.meetings.mailer.invite_join_meeting_mailer")
            mail(to: user.email, subject: subject)
          end
        end

        private

        def routes
          @router ||= Decidim::EngineRouter.main_proxy(@meeting.feature)
        end
      end
    end
  end
end
