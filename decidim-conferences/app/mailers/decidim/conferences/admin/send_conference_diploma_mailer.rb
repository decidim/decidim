# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A custom mailer for sending the diploma of the conference to
      # a registered user who attends to the conference.
      class SendConferenceDiplomaMailer < Decidim::ApplicationMailer
        include Decidim::TranslationsHelper
        include Decidim::SanitizeHelper

        helper Decidim::ResourceHelper
        helper Decidim::TranslationsHelper

        # Send an email to an user with the diploma of conference attendance attached.
        #
        # user - The user being invited
        # conference - The conference being joined.
        def diploma(conference, user)
          with_user(user) do
            @user = user
            @conference = conference
            @organization = @conference.organization
            @locator = Decidim::ResourceLocatorPresenter.new(@conference)

            add_diploma_attachment

            subject = I18n.t("diploma.subject", scope: "decidim.conferences.mailer.send_conference_diploma_mailer")
            mail(to: user.email, subject:)
          end
        end

        private

        def add_diploma_attachment
          diploma = WickedPdf.new.pdf_from_string(
            render_to_string(pdf: "conference-diploma",
                             template: "decidim/conferences/admin/send_conference_diploma_mailer/diploma_user",
                             layout: "decidim/diploma"),
            orientation: "Landscape"
          )

          attachments["conference-#{@user.nickname.parameterize}-diploma.pdf"] = diploma
        end
      end
    end
  end
end
