# frozen_string_literal: true
require "decidim/form_builder"

module Decidim
  # This custom FormBuilder is used to create resource filter forms
  class FilterFormBuilder < FormBuilder
    # Wrap the radio buttons collection in a custom fieldset.
    # It also renders the inputs inside its labels.
    def collection_radio_buttons(method, collection, value_method, label_method, options = {}, html_options = {}, &block)
      fieldset_wrapper options[:legend_title] do
        super(method, collection, value_method, label_method, options, html_options) do |b|
          if block_given?
            block.call b
          else
            b.label { b.radio_button + b.text }
          end
        end
      end
    end

    # Wrap the check_boxes collection in a custom fieldset.
    # It also renders the inputs inside its labels.    
    def collection_check_boxes(method, collection, value_method, label_method, options = {}, html_options = {}, &block)
      fieldset_wrapper options[:legend_title] do
        super(method, collection, value_method, label_method, options, html_options) do |b|
          if block_given?
            block.call b
          else
            b.label { b.check_box + b.text }
          end
        end
      end
    end

    # Wrap the category select in a custom fieldset.
    def categories_select(method, collection, options = {})
      fieldset_wrapper options[:legend_title] do
        super(method, collection, options)
      end
    end

    private

    # Private: Renders a custom fieldset and execute the given block.
    def fieldset_wrapper(legend_title, &block)
      @template.content_tag(:div, '', class: "filters__section") do
        @template.content_tag(:fieldset) do
          @template.content_tag(:legend) do
            @template.content_tag(:h6, legend_title, class: 'heading6')
          end + block.call
        end
      end
    end
  end
end