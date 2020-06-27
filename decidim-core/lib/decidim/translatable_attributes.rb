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
      #
      # Example:
      #
      #   translatable_attribute(:name, String)
      #   # This will generate: `name_ca`, `name_en`, `name_ca=`, `name_en=`
      #   # and will keep them synchronized with a hash in `name`:
      #   # name = { "ca" => "Hola", "en" => "Hello" }
      #
      # Returns nothing.
      def translatable_attribute(name, type, *options)
        attribute name, Hash, default: {}

        locales.each do |locale|
          attribute_name = "#{name}_#{locale}".gsub("-", "__")
          attribute attribute_name, type, *options

          define_method attribute_name do
            field = public_send(name) || {}
            field[locale.to_s] || field[locale.to_sym]
          end

          define_method "#{attribute_name}=" do |value|
            field = public_send(name) || {}
            public_send("#{name}=", field.merge(locale => super(value)))
          end
        end
      end

      def locales
        Decidim.available_locales
      end
    end

    included do
      ActiveSupport::Deprecation.warn('translated_attribute helper is deprecated, please use translate')
      # Public: Returns the translation of an attribute using the current locale,
      # if available. Checks for the organization default locale as fallback.
      #
      # attribute - A Hash where keys (strings) are locales, and their values are
      #             the translation for each locale.
      #
      # organization - An optional Organization to get the default locale from.
      #
      # Returns a String with the translation.

      def translated_attribute(attribute, organization = nil)
        #rubocop:enable Decidim/TranslatedAttribute
        return "" if attribute.nil?
        return attribute unless attribute.is_a?(Hash)
        attribute = attribute.dup.stringify_keys
        organization ||= try(:current_organization)
        organization_locale = organization.try(:default_locale)

        attribute[I18n.locale.to_s].presence ||
          attribute[organization_locale].presence ||
          attribute[attribute.keys.first].presence ||
          ""
      end

      def translated(resource, field)
        return "" if resource[field].nil?

        resource[field] = resource[field].dup.stringify_keys
        organization ||= try(:current_organization)
        organization_locale = organization.try(:default_locale)

        @translated_value = Decidim::TranslatedField.find_by(
          translated_resource_id: resource.id,
          translated_resource_type: resource.class.name,
          field_name: field.to_s,
          translation_locale: I18n.locale.to_s
        ).translation_value

        resource[field][I18n.locale.to_s].presence ||
        resource[field][organization_locale].presence ||
        resource[field][resource[field].keys.first].presence ||
        @translated_value.presence ||
          ""

      end
    end
  end
end
