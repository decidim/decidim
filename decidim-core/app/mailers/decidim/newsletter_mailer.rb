# frozen_string_literal: true
module Decidim
  class NewsletterMailer < ApplicationMailer
    add_template_helper Decidim::TranslationsHelper

    def newsletter(user, newsletter)
      @organization = user.organization
      @newsletter = newsletter

      with_user(user) do
        roadie_mail(to: user.email, subject: @newsletter.subject[I18n.locale.to_s])
      end
    end
  end
end
