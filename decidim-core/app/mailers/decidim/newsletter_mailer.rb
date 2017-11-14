# frozen_string_literal: true

module Decidim
  class NewsletterMailer < ApplicationMailer
    helper Decidim::SanitizeHelper
    add_template_helper Decidim::TranslationsHelper

    def newsletter(user, newsletter)
      @organization = user.organization
      @newsletter = newsletter

      with_user(user) do
        @subject = parse_interpolations(@newsletter.subject[I18n.locale.to_s], user)
        @body = parse_interpolations(@newsletter.body[I18n.locale.to_s], user)

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end

    private

    def parse_interpolations(content, user)
      content.gsub("%{name}", user.name)
    end
  end
end
