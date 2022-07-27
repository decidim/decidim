# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A custom mailer for sending an invitation to join a meeting to
      # an existing user.
      class InviteJoinMeetingMailer < Decidim::ApplicationMailer
        include Decidim::TranslationsHelper
        include Decidim::SanitizeHelper
        include Decidim::ApplicationHelper

        helper Decidim::ResourceHelper
        helper Decidim::TranslationsHelper
        helper Decidim::ApplicationHelper

        helper_method :routes

        # Send an email to an user to invite them to join a meeting.
        #
        # user - The user being invited
        # meeting - The meeting being joined.
        # invited_by - The user performing the invitation.
        def invite(user, meeting, invited_by)
          with_user(user) do
            @user = user
            @meeting = meeting
            @invited_by = invited_by
            @organization = @meeting.organization
            @locator = Decidim::ResourceLocatorPresenter.new(@meeting)

            subject = I18n.t("invite.subject", scope: "decidim.meetings.mailer.invite_join_meeting_mailer")
            mail(to: user.email, subject:)
          end
        end

        private

        def routes
          @routes ||= Decidim::EngineRouter.main_proxy(@meeting.component)
        end
      end
    end
  end
end
