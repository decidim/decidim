# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A set of convenient methods to generate dynamic jsonb objects in a way is
  # compatible with AttirubteObject and ActiveModel thus making it easy to
  # integrate into Rails forms and similar workflows.
  module JsonbAttributes
    extend ActiveSupport::Concern

    class_methods do
      # Public: Mirrors the `attribute` interface to define attributes in
      # custom jsonb objects.
      #
      # name - Attribute's name
      # fields - The attribute's child fields
      #
      # Example:
      #   jsonb_attribute(:settings, [[:custom_setting, String], [:another_setting, Boolean])
      #   # This will generate `custom_setting`, `custom_setting=` and
      #   # `another_setting`, `another_setting=` and will keep them
      #   # syncronized with a hash in `settings`:
      #   # settings = { "custom_setting" => "demo", "another_setting" => "demo"}
      #
      # Returns nothing.
      def jsonb_attribute(name, fields, *options)
        attribute(name, { String => Object }, default: {})

        fields.each do |f, type|
          attribute f, type, *options
          define_method f do
            field = public_send(name) || {}
            field[f.to_s] || field[f.to_sym]
          end

          define_method "#{f}=" do |value|
            field = public_send(name) || {}
            value_type = self.class.attribute_types[f.to_s]
            value = value_type.cast(value) if value_type
            public_send("#{name}=", field.merge(f => super(value)))
          end
        end
      end
    end
  end
end
