# frozen_string_literal: true

module Decidim
  # Helper that provides a single method to create datalist select.
  module DatalistSelectHelper
    # Public: Creates HTML for datalist select so that you can use seperate ids and labels.
    #
    # items - Items in datalist, item should have id and name.
    # options - a Hash with options
    #           :id - id of wrapper
    #           :class - wrapper css classes
    #           :data - wrapper data attributes
    #           :label - label for input
    #           :name - name of input
    #           :autocomplete - enable or disable autocomplete provided by browser.
    #           :list - id of datalist
    # yield - additional html (e.g. hidden input)
    #
    # Returns a HTML String div containing following children: label, input and datalist elements.
    def datalist_select(items, options = {})
      default_options = {
        list: "datalist-list",
        autocomplete: "off"
      }
      options = default_options.merge(options)
      tag.div(id: options[:id], class: options[:class], data: options[:data]) do
        html = ""
        html += yield if block_given?
        html += tag.label(options[:label], for: options[:name])
        html += tag.input(type: "text", name: options[:name], list: options[:list], autocomplete: options[:autocomplete], placeholder: options[:placeholder])
        html += tag.datalist(id: options[:list]) do
          items.map do |item|
            tag.option(translated_attribute(item.name), data: { value: item.id })
          end.join.html_safe
        end
        html.html_safe
      end
    end
  end
end
