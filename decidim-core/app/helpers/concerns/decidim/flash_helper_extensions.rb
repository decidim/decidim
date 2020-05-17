# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module FlashHelperExtensions
    extend ActiveSupport::Concern

    included do
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
        options = { class: "flash callout #{alert_class}" }
        options[:data] = { closable: "" } if closable
        options[:role] = "alert"
        content_tag(:div, options) do
          concat value
          concat close_link if closable
        end
      end
    end
  end
end
