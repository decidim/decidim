# frozen_string_literal: true

module Decidim
  module Initiatives
    # Mailer for initiatives engine.
    class InitiativesMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      helper Decidim::TranslatableAttributes
      helper Decidim::SanitizeHelper

      # Notifies initiative creation
      def notify_creation(initiative)
        return if initiative.author.email.blank?

        @initiative = initiative
        @organization = initiative.organization

        with_user(initiative.author) do
          @subject = I18n.t(
            "decidim.initiatives.initiatives_mailer.creation_subject",
            title: translated_attribute(initiative.title)
          )

          mail(to: "#{initiative.author.name} <#{initiative.author.email}>", subject: @subject)
        end
      end

      # Notify changes in state
      def notify_state_change(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization

        with_user(user) do
          @subject = I18n.t(
            "decidim.initiatives.initiatives_mailer.status_change_for",
            title: translated_attribute(initiative.title)
          )

          @body = I18n.t(
            "decidim.initiatives.initiatives_mailer.status_change_body_for",
            title: translated_attribute(initiative.title),
            state: I18n.t(initiative.state, scope: "decidim.initiatives.admin_states")
          )

          @link = initiative_url(initiative, locale: I18n.locale, host: @organization.host)

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify progress to all initiative subscribers.
      def notify_progress(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, locale: I18n.locale, host: @organization.host)

        with_user(user) do
          @body = I18n.t(
            "decidim.initiatives.initiatives_mailer.progress_report_body_for",
            title: translated_attribute(initiative.title),
            percentage: initiative.percentage
          )

          @subject = I18n.t(
            "decidim.initiatives.initiatives_mailer.progress_report_for",
            title: translated_attribute(initiative.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end
    end
  end
end
