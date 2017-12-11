# frozen_string_literal: true

module Decidim
  class NewsletterMailer < ApplicationMailer
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    add_template_helper Decidim::TranslationsHelper

    def newsletter(user, newsletter)
      @organization = user.organization
      @newsletter = newsletter

      with_user(user) do
        @subject = parse_interpolations(@newsletter.id, @newsletter.subject[I18n.locale.to_s], user)
        @body = parse_interpolations(@newsletter.id, @newsletter.body[I18n.locale.to_s], user)

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end

  end
end
