# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to "standardize" the newline characters within
    # strings that are sent through user entered forms. This strips out the
    # carriage return characters from the strings in order to avoid validation
    # mismatches with the string lengths between the frontend and the backend.
    #
    # This type should be used with forms that have:
    # - A user input defined with the <textarea> element
    # - The input element having the `maxlength` attribute defined for it
    # - The backend having a maximum length validation for the input
    class CleanString < ActiveModel::Type::Value
      def type # :nodoc:
        :"decidim/attributes/clean_string"
      end

      private

      # When using Windows or copying texts from existing documents, the text
      # can contain the carriage return characters (\r) that the front-end
      # character counter does not consider as actual characters. This happens
      # because the character counter currently counts the characters using
      # jQuery's `$input.val()` method which strips out the carriage return
      # characters as explained at:
      #   https://api.jquery.com/val/
      #
      #   Note: At present, using .val() on <textarea> elements strips carriage
      #   return characters from the browser-reported value.
      #
      # The backend, on the other hand, calculates these as characters as they
      # are included in the data that gets sent to the server. In order to fix
      # this mismatch, remove the carriage return characters from the text
      # using this attribute type.
      def cast_value(value)
        return value unless value.is_a?(String)

        value.gsub(/\r/, "")
      end
    end
  end
end
