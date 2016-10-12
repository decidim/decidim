# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A module to be included in mailers that changes the default behaviour so
  # the emails are rendered in the user's locale instead of the default one.
  module LocalisedMailer
    extend ActiveSupport::Concern

    included do
      # Yields with the I18n locale changed to the user's one.
      #
      # Returns nothing.
      def with_user(user)
        I18n.with_locale(user.locale || I18n.locale) do
          yield
        end
      end

      # Overwrite default devise_mail method to always render the email with
      # the user's locale.
      def devise_mail(record, action, opts = {})
        with_user(record) do
          super
        end
      end
    end
  end
end
