# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to switch between locales.
  module LocaleSwitcher
    extend ActiveSupport::Concern

    included do
      before_action :set_locale
      helper_method :current_locale, :available_locales

      # Sets the locale for the current session.
      #
      # Returns nothing.
      def set_locale
        I18n.locale = if params["locale"] && available_locales.include?(params["locale"])
                        params["locale"]
                      elsif current_user && current_user.locale.present?
                        current_user.locale
                      else
                        I18n.default_locale
                      end
      end

      # Adds the current locale to all the URLs generated by url_for so users
      # experience a consistent behaviour if they copy or share links.
      #
      # Returns a Hash.
      def default_url_options
        return {} if current_locale == I18n.default_locale.to_s

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
        @available_locales ||= I18n.available_locales.map(&:to_s)
      end
    end
  end
end
