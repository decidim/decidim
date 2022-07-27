# frozen_string_literal: true

module Decidim
  module Budgets
    class VoteReminderMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper

      helper Decidim::TranslationsHelper

      helper_method :routes

      # Send the user an email reminder to finish voting
      #
      # reminder - the reminder to send.
      def vote_reminder(reminder)
        @reminder = reminder
        @user = reminder.user
        with_user(@user) do
          @orders = reminder.records.active.map(&:remindable)
          @organization = @user.organization

          subject = I18n.t(
            "decidim.budgets.vote_reminder_mailer.vote_reminder.email_subject",
            count: @orders.count
          )

          mail(to: @user.email, subject:)
        end
      end

      private

      def routes
        @routes ||= Decidim::EngineRouter.main_proxy(@reminder.component)
      end
    end
  end
end
