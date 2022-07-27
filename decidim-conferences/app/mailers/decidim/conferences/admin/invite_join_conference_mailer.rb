# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A custom mailer for sending an invitation to join a conference to
      # an existing user.
      class InviteJoinConferenceMailer < Decidim::ApplicationMailer
        include Decidim::TranslationsHelper
        include Decidim::SanitizeHelper

        helper Decidim::ResourceHelper
        helper Decidim::TranslationsHelper

        helper_method :routes

        # Send an email to an user to invite them to join a conference.
        #
        # user - The user being invited
        # conference - The conference being joined.
        # invited_by - The user performing the invitation.
        def invite(user, conference, registration_type, invited_by)
          with_user(user) do
            @user = user
            @conference = conference
            @invited_by = invited_by
            @organization = @conference.organization
            @locator = Decidim::ResourceLocatorPresenter.new(@conference)
            @registration_type = registration_type

            subject = I18n.t("invite.subject", scope: "decidim.conferences.mailer.invite_join_conference_mailer")
            mail(to: user.email, subject:)
          end
        end

        private

        def routes
          @routes ||= Decidim::EngineRouter.main_proxy(@conference)
        end
      end
    end
  end
end
