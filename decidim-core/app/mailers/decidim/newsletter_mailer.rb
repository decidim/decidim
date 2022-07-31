# frozen_string_literal: true

module Decidim
  class NewsletterMailer < ApplicationMailer
    helper Decidim::SanitizeHelper
    helper Decidim::TranslationsHelper

    include Decidim::NewslettersHelper

    layout "decidim/newsletter_base"

    helper_method :cell

    def newsletter(user, newsletter, preview: false)
      return if user.email.blank?

      @organization = user.organization
      @newsletter = newsletter
      @user = user
      @preview = preview

      @custom_url_for_mail_root = custom_url_for_mail_root(@organization, @newsletter.id) if Decidim.config.track_newsletter_links
      @encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(@user.id, @newsletter.sent_at)

      with_user(user) do
        uninterpolated_subject =
          @newsletter.subject[I18n.locale.to_s].presence || @newsletter.subject[@organization.default_locale]

        @subject = parse_interpolations(uninterpolated_subject, user, @newsletter.id)

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end

    private

    def cell
      @cell ||= ::Decidim::ViewModel.cell(
        @newsletter.template.cell,
        @newsletter.template,
        organization: @organization,
        newsletter: @newsletter,
        recipient_user: @user,
        context: {
          controller: self
        }
      )
    end
  end
end
