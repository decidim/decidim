# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module FlashHelperExtensions
    extend ActiveSupport::Concern

    included do
      # Displays the flash messages found in ActionDispatch's +flash+ hash using
      # Foundation's +callout+ component.
      #
      # Overrides original function from foundation_rails_helper gem to allow
      # flash messages with links inside.
      #
      # Parameters:
      # * +closable+ - A boolean to determine whether the displayed flash messages
      # should be closable by the user. Defaults to true.
      # * +key_matching+ - A Hash of key/value pairs mapping flash keys to the
      # corresponding class to use for the callout box.
      def display_flash_messages(closable: true, key_matching: {})
        key_matching = FoundationRailsHelper::FlashHelper::DEFAULT_KEY_MATCHING.merge(key_matching)
        key_matching.default = :primary

        capture do
          flash.each do |key, value|
            next if ignored_key?(key.to_sym)

            alert_class = key_matching[key.to_sym]
            concat alert_box(value.try(:html_safe), alert_class, closable)
          end
        end
      end

      private

      # Private: Foundation alert box.
      #
      # Overrides the foundation alert box helper for adding accessibility tags.
      #
      # value - The flash message.
      # alert_class - The foundation class of the alert message.
      # closable - A boolean indicating whether the close icon is added.
      #
      # Returns a HTML string.
      def alert_box(value, alert_class, closable, opts = {})
        options = {
          class: "flash #{alert_class}",
          data: { "alert-box": "" },
          role: "alert",
          aria: { atomic: "true" }
        }.merge(opts)

        options[:data] = options[:data].merge(closable: "") if closable
        icon = {
          secondary: "information-line",
          alert: "alert-line",
          warning: "alert-line",
          success: "checkbox-circle-line"
        }
        content_tag(:div, options) do
          concat icon(icon[alert_class])
          concat message(value)
          concat close_link if closable
        end
      end

      # Private: Foudation alert box close link.
      #
      # Overrides the foundation alert box close link helper for the aria-label
      # translations.
      def close_link
        button_tag(
          class: "close-button",
          type: "button",
          data: { close: "" },
          aria: { label: I18n.t("decidim.alert.dismiss") }
        ) do
          icon "close-line"
        end
      end

      def message(value)
        return content_tag(:span, value, class: "flash__message") unless value.is_a?(Hash)

        content_tag(:span, class: "flash__message") do
          concat value[:title]
          concat content_tag(:span, value[:body], class: "flash__message-body")
        end
      end
    end
  end
end
