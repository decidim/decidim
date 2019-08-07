# frozen_string_literal: true

module Decidim
  # A helper that converts an array of locale IDs (two-letter identifiers, e.g.
  # `"en"`) to an array of Objects that have both the ID and their name in
  # their own language (e.g., `"English"`).
  #
  # This is intended to be used in forms, when selecting the default locale
  # form a given list, or when creating a list of radio buttons, for example.
  #
  # Examples:
  #
  #   <%= form.collection_select :default_locale, localized_locales(current_organization.available_locales), :id, :name %>
  #
  #   <% localized_locales(current_organization.available_locales).each do |locale| %>
  #     <p><%= locale.name %></p>
  #   <% end %>
  #
  module LocalizedLocalesHelper
    # Converts a given array of strings to an array of Objects representing
    # locales.
    #
    # collection - an Array of Strings. By default it uses all the available
    #   locales in Decidim, but you can passa nother collection of locales (for
    #   example, the available locales for an organization)
    def localized_locales(collection = Decidim.available_locales)
      klass = Class.new do
        def initialize(locale)
          @locale = locale
        end

        def id
          @locale.to_s
        end

        def name
          I18n.with_locale(@locale) { I18n.t("name", scope: "locale") }
        end
      end

      collection.map { |locale| klass.new(locale) }
    end
  end
end
