# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to switch between locales.
  module LocaleSwitcher
    extend ActiveSupport::Concern

    included do
      around_action :switch_locale
      helper_method :current_locale, :available_locales, :default_locale

      # Sets the locale for the current session.
      #
      # Returns nothing.
      def switch_locale(&action)
        locale = if params["locale"]
                   params["locale"]
                 elsif current_user && current_user.locale.present?
                   current_user.locale
                 end

        I18n.with_locale(available_locales.include?(locale) ? locale : default_locale, &action)
      end

      # Adds the current locale to all the URLs generated by url_for so users
      # experience a consistent behaviour if they copy or share links.
      #
      # Returns a Hash.
      def default_url_options
        return {} if current_locale == default_locale.to_s

        { locale: current_locale }
      end

      # The current locale for the user. Available as a helper for the views.
      #
      # Returns a String.
      def current_locale
        @current_locale ||= I18n.locale.to_s
      end

      # The available locales in the application. Available as a helper for the
      # views.
      #
      # Returns an Array of Strings.
      def available_locales
        @available_locales ||= (current_organization || Decidim).public_send(:available_locales)
      end

      # The default locale of this organization.
      #
      # Returns a String with the default locale.
      def default_locale
        @default_locale ||= (current_organization || Decidim).public_send(:default_locale)
      end
    end
  end
end
