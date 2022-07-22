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
      def alert_box(value, alert_class, closable)
        options = {
          class: "flash callout #{alert_class}",
          role: "alert",
          aria: { atomic: "true" }
        }
        options[:data] = { closable: "" } if closable
        content_tag(:div, options) do
          concat value
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
          content_tag(:span, "&times;".html_safe, aria: { hidden: true })
        end
      end
    end
  end
end
