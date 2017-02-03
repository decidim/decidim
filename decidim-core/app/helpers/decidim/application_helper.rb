# encoding: utf-8
# frozen_string_literal: true
module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    include Decidim::MetaTagsHelper

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

      Truncato.truncate(text, options)
    end

    # A custom form for that injects client side validations with Abide.
    #
    # record - The object to build the form for.
    # options - A Hash of options to pass to the form builder.
    # &block - The block to execute as content of the form.
    #
    # Returns a String.
    def decidim_form_for(record, options = {}, &block)
      options[:data] ||= {}
      options[:data].update(abide: true, "live-validate" => true, "validate-on-blur" => true)
      form_for(record, options, &block)
    end
  end
end
