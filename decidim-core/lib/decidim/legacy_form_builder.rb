# frozen_string_literal: true

# Copyright (c) 2015 Sébastien Gruhier (http://xilinus.com/) - MIT LICENSE
#
# This file has been copied and modified from https://github.com/sgruhier/foundation_rails_helper/blob/master/lib/foundation_rails_helper/form_builder.rb
# We have done this so we can decouple Decidim from this dependency, which is not updated to Rails 7.1
# We also plan to fully remove Foundation CSS legacy code in the future

module Decidim
  class LegacyFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper
    %w(file_field email_field text_field text_area url_field
       number_field date_field datetime_field search_field color_field)
      .each do |method_name|
      define_method(method_name) do |*args|
        attribute = args[0]
        options = args[1] || {}
        field(attribute, options) do |opts|
          super(attribute, opts)
        end
      end
    end

    def label(attribute, text = nil, options = {})
      if error?(attribute)
        options[:class] ||= ""
        options[:class] += " is-invalid-label"
      end

      super(attribute, (text || "").html_safe, options)
    end

    def radio_button(attribute, tag_value, options = {})
      options[:label_options] ||= {}
      label_options = options.delete(:label_options)&.merge!(value: tag_value)
      label_text = options.delete(:label)
      l = label(attribute, label_text, label_options) unless label_text == false
      r = @template.radio_button(@object_name, attribute, tag_value,
                                 objectify_options(options))

      "#{r}#{l}".html_safe
    end

    def datetime_select(attribute, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, options, html_opts.merge(autocomplete: :off))
      end
    end

    def date_select(attribute, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, options, html_opts.merge(autocomplete: :off))
      end
    end

    def time_zone_select(attribute, priorities = nil, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, priorities, options,
              html_opts.merge(autocomplete: :off))
      end
    end

    def select(attribute, choices, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        html_options[:autocomplete] ||= :off
        super(attribute, choices, options, html_opts)
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        html_options[:autocomplete] ||= :off
        super(attribute, collection, value_method, text_method, options,
              html_opts)
      end
    end
    # rubocop:enable Metrics/ParameterLists

    def autocomplete(attribute, url, options = {})
      field attribute, options do |opts|
        opts.merge!(update_elements: opts[:update_elements],
                    min_length: 0, value: object.send(attribute))
        autocomplete_field(attribute, url, opts)
      end
    end

    def submit(value = nil, options = {})
      options[:class] ||= "button"
      super
    end

    def error_for(attribute, options = {})
      return unless error?(attribute)

      class_name = "form-error is-visible"
      class_name += " #{options[:class]}" if options[:class]

      error_messages = object.errors[attribute].join(", ")
      error_messages = error_messages.html_safe if options[:html_safe_errors]
      content_tag(:small, error_messages,
                  class: class_name.sub("is-invalid-input", ""))
    end

    private

    def error?(attribute)
      object.respond_to?(:errors) && object.errors[attribute].present?
    end

    def default_label_text(object, attribute)
      return object.class.human_attribute_name(attribute) if object.class.respond_to?(:human_attribute_name)

      attribute.to_s.humanize
    end
  end
end
