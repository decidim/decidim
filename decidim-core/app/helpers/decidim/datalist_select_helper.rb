# frozen_string_literal: true

module Decidim
  # Helper that provides a single method to create datalist select.
  module DatalistSelectHelper
    # Public: Returns HTML elements needed for datalist select: label, input and datalist with options.
    #
    # items - Items in datalist, item should have id and name.
    # options - a Hash with options
    #           :label - label for input
    #           :name - name of input
    #           :type - input type
    #           :autocomplete - enable or disable autocomplete provided by browser.
    #           :list - id of datalist
    # yield - additional html (e.g. hidden input)
    #
    # Returns a String containing HTML (label, input and datalist elements).
    def datalist_select(items, options = {})
      default_options = {
        type: "text",
        list: "datalist-list",
        autocomplete: "off"
      }
      options = default_options.merge(options)
      html = ""
      html += yield if block_given?
      html += tag.label(options[:label], for: options[:name])
      html += tag.input(type: options[:type], name: options[:name], list: options[:list], autocomplete: options[:autocomplete])
      html += tag.datalist(id: options[:list]) do
        items.map do |item|
          tag.option(translated_attribute(item.name), data: { value: item.id })
        end.join.html_safe
      end
      html.html_safe
    end
  end
end
