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
      # type - The attribute's Type
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
            translatable_attribute_getter(name, locale)
          end

          alias_method "#{attribute_name}_virtus=", "#{attribute_name}="

          define_method "#{attribute_name}=" do |value|
            new_value = send("#{attribute_name}_virtus=", value)
            translatable_attribute_setter(name, locale, new_value)
          end
        end
      end

      def locales
        Decidim.available_locales
      end
    end

    private

    def translatable_attribute_setter(name, locale, value)
      public_send("#{name}=", (public_send(name) || {}).merge(locale => value))
    end

    def translatable_attribute_getter(name, locale)
      field = public_send(name) || {}
      corrected_locale = locale.to_s.gsub("__", "-")
      field[corrected_locale] || field[corrected_locale.to_sym]
    end
  end
end
