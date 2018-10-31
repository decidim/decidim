# frozen_string_literal: true

module Decidim
  class NewsletterMailer < ApplicationMailer
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    add_template_helper Decidim::TranslationsHelper

    def newsletter(user, newsletter)
      return if user.email.blank?

      @organization = user.organization
      @newsletter = newsletter
      @user = user

      @custom_url_for_mail_root = custom_url_for_mail_root(@organization, @newsletter.id) if Decidim.config.track_newsletter_links
      @encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(@user.id, @newsletter.sent_at)
      with_user(user) do
        @subject = parse_interpolations(@newsletter.subject[I18n.locale.to_s], user, @newsletter.id)
        @body = parse_interpolations(@newsletter.body[I18n.locale.to_s], user, @newsletter.id)

        mail(from: Decidim.config.mailer_sender, to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end
  end
end
