# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A set of convenience methods to deal with attachment attributes for
  # models that may set the attachment records through the original model
  # (Decidim::Attachment) or through the user submitted form data (String).
  module AttachmentAttributes
    extend ActiveSupport::Concern

    class_methods do
      # Public: Mirrors the `attribute` interface to define attachment
      # attributes for form objects.
      #
      # name - The attribute's name
      #
      #
      # Example:
      #
      #   attachment_attribute :photos
      #   # This will create two attributes of the following types:
      #   #   attribute :photos, Array[Integer]
      #   #   attribute :add_photos, Array
      #   # In addition, it will generate the getter method for the attribute
      #   # returning an array of the Decidim::Attachment records.
      #
      # Returns nothing.
      def attachments_attribute(name)
        attribute name, Array[Integer]
        attribute "add_#{name}".to_sym, Array

        # Define the getter method that fetches the attachment records based on
        # their types. For Strings and Integers, assumes they are IDs and will
        # fetch the attachment record matching that ID.
        variable_name = "@#{name}_records"
        define_method name do
          return instance_variable_get(variable_name) if instance_variable_defined?(variable_name)

          original = @attributes[name.to_s].value_before_type_cast
          return original if original && !original.is_a?(Array)

          instance_variable_set(
            variable_name,
            super().map do |attachment|
              if attachment.is_a?(Integer)
                Decidim::Attachment.find_by(id: attachment)
              else
                attachment
              end
            end.compact
          )
        end
      end
    end
  end
end
