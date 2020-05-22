# frozen_string_literal: true

module Decidim
  class NewsletterMailer < ApplicationMailer
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    layout "decidim/newsletter_base"

    add_template_helper Decidim::TranslationsHelper

    helper_method :cell

    def newsletter(user, newsletter)
      return if user.email.blank?

      @organization = user.organization
      @newsletter = newsletter
      @user = user

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

    # Internal: Helper method to include cells in the mailer layouts.
    def cell(name, model = nil, options = {}, constant = ::Decidim::ViewModel, &block)
      options[:context] ||= {}
      options[:context][:controller] = self

      constant.cell(name, model, options, &block)
    end
  end
end
