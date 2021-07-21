# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A set of convenience methods to deal with I18n attributes and validations
  # in a way that's compatible with Virtus and ActiveModel, thus making it easy
  # to integrate into Rails' forms and similar workflows.
  module TranslatableAttributes
    extend ActiveSupport::Concern

    class_methods do
      # Public: Mirrors Virtus' `attribute` interface to define attributes in
      # multiple locales.
      #
      # name - The attribute's name
      # type - The attribute's type
      # options - Options to send to the form class when defining the attribute.
      # block - An optional block to be called for each attribute name and
      # locale. The block will receive two arguments, one with the attriubte
      # name and another with the locale.
      #
      #
      # Example:
      #
      #   translatable_attribute(:name, String)
      #   # This will generate: `name_ca`, `name_en`, `name_ca=`, `name_en=`
      #   # and will keep them synchronized with a hash in `name`:
      #   # name = { "ca" => "Hola", "en" => "Hello" }
      #
      #   translatable_attribute(:name, String) do |name, locale|
      #     # Do something, like adding validations.
      #     # name would be `name_ca`, `name_en` and locale `ca` and `en`.
      #   end
      #
      # Returns nothing.
      def translatable_attribute(name, type, *options)
        attribute name, Hash, default: {}

        locales.each do |locale|
          attribute_name = "#{name}_#{locale}".gsub("-", "__")
          attribute attribute_name, type, *options

          define_method attribute_name do
            field = public_send(name) || {}
            value = field[locale.to_s] || field[locale.to_sym]
            attribute_set[attribute_name].coerce(value)
          end

          define_method "#{attribute_name}=" do |value|
            field = public_send(name) || {}
            public_send("#{name}=", field.merge(locale => super(value)))
          end

          yield(attribute_name, locale) if block_given?
        end
      end

      def locales
        Decidim.available_locales
      end
    end

    included do
      # Public: Returns the translation of an attribute using the current locale,
      # if available. Checks for the organization default locale as fallback.
      #
      # attribute - A Hash where keys (strings) are locales, and their values are
      #             the translation for each locale.
      #
      # given_organization - An optional Organization to get the default locale from.
      #
      # Returns a String with the translation.
      def translated_attribute(attribute, given_organization = nil)
        return "" if attribute.nil?
        return attribute unless attribute.is_a?(Hash)

        attribute = attribute.dup.stringify_keys
        given_organization ||= try(:current_organization)
        given_organization ||= try(:organization)
        organization_locale = given_organization.try(:default_locale)

        attribute[I18n.locale.to_s].presence ||
          machine_translation_value(attribute, given_organization) ||
          attribute[organization_locale].presence ||
          attribute[attribute.keys.first].presence ||
          ""
      end

      # Detects whether we need to show the machine translated version of the
      # field, or not.
      #
      # It uses `RequestStore` so that the method works from inside presenter
      # classes, which don't have access to controller instance variables.
      def machine_translation_value(attribute, organization)
        return unless organization
        return unless organization.enable_machine_translations?

        attribute.dig("machine_translations", I18n.locale.to_s).presence if must_render_translation?(organization)
      end

      def must_render_translation?(organization)
        translations_prioritized = organization.machine_translation_prioritizes_translation?
        translations_toggled = RequestStore.store[:toggle_machine_translations]

        translations_prioritized != translations_toggled
      end
    end

    def default_locale?(locale)
      locale.to_s == try(:default_locale).to_s ||
        locale.to_s == try(:current_organization).try(:default_locale).to_s
    end
  end
end
