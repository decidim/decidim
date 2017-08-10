# frozen_string_literal: true

module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    include Decidim::OmniauthHelper
    include Decidim::ScopesHelper

    # Truncates a given text respecting its HTML tags.
    #
    # text    - The String text to be truncated.
    # options - A Hash with the options to truncate the text (default: {}):
    #           :length - An Integer number with the max length of the text.
    #           :separator - A String to append to the text when it's being
    #           truncated. See `truncato` gem for more options.
    #
    # Returns a String.
    def html_truncate(text, options = {})
      options[:max_length] = options.delete(:length) || options[:max_length]
      options[:tail] = options.delete(:separator) || options[:tail] || "..."
      options[:count_tags] ||= false
      options[:count_tail] ||= false
      options[:tail_before_final_tag] ||= true

      Truncato.truncate(text, options)
    end
  end
end
