# frozen_string_literal: true
module Decidim
  # A heper to expose an easy way to add authorization forms in a view.
  module DecidimFormHelper
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

    # A custom helper to include an editor field without requiring a form object
    #
    # name - The input name
    # value - The input value
    # options - The set of options to send to the field
    #           :label   - The Boolean value to create or not the input label (optional) (default: true)
    #           :toolbar - The String value to configure WYSIWYG toolbar. It should be 'basic' or
    #                      or 'full' (optional) (default: 'basic')
    #           :lines   - The Integer to indicate how many lines should editor have (optional)
    #
    # Returns a rich editor to be included in a html template.
    def editor_field_tag(name, value, options = {})
      options[:toolbar] ||= "basic"
      options[:lines] ||= 10

      content_tag(:div, class: "editor") do
        template = ""
        template += label_tag(name, options[:label]) if options[:label] != false
        template += hidden_field_tag(name, value, options)
        template += content_tag(:div, nil, class: "editor-container", data: {
                                  toolbar: options[:toolbar]
                                }, style: "height: #{options[:lines]}rem")
        template.html_safe
      end
    end

    # A custom helper to include a translated field without requiring a form object.
    #
    # type        - The type of the translated input field.
    # object_name - The object name used to identify the Foundation tabs.
    # name        - The name of the input which will be suffixed with the corresponding locales.
    # value       - A hash containing the value for each locale.
    # options     - An optional hash of options.
    #             * tabs_id: The id to identify the Foundation tabs element.
    #             * label: The label used for the field.
    #
    # Returns a Foundation tabs element with the translated input field.
    def translated_field_tag(type, object_name, name, value = {}, options = {})
      locales = Decidim.available_locales

      tabs_id = options[:tabs_id] || "#{object_name}-#{name}-tabs"
      enabled_tabs = options[:enable_tabs].nil? ? true : options[:enable_tabs]
      tabs_panels_data = enabled_tabs ? { tabs: true } : {}

      if locales.count == 1
        return send(
          type,
          "#{name}_#{locales.first.to_s.gsub("-", "__")}",
          options.merge(label: options[:label])
        )
      end

      label_tabs = content_tag(:div, class: "label--tabs") do
        field_label = label_tag(name, options[:label])

        tabs_panels = "".html_safe
        if options[:label] != false
          tabs_panels = content_tag(:ul, class: "tabs tabs--lang", id: tabs_id, data: tabs_panels_data) do
            locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
              string + content_tag(:li, class: tab_element_class_for("title", index)) do
                title = I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
                tab_content_id = "#{tabs_id}-#{name}-panel-#{index}"
                content_tag(:a, title, href: "##{tab_content_id}")
              end
            end
          end
        end

        safe_join [field_label, tabs_panels]
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          tab_content_id = "#{tabs_id}-#{name}-panel-#{index}"
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: tab_content_id) do
            send(type, "#{object_name}[#{name_with_locale(name, locale)}]", value[locale], options.merge(id: "#{tabs_id}_#{name}_#{locale}", label: false))
          end
        end
      end

      safe_join [label_tabs, tabs_content]
    end

    # Helper method used by `translated_field_tag`
    def tab_element_class_for(type, index)
      element_class = "tabs-#{type}"
      element_class += " is-active" if index.zero?
      element_class
    end

    # Helper method used by `translated_field_tag`
    def name_with_locale(name, locale)
      "#{name}_#{locale.to_s.gsub("-", "__")}"
    end
  end
end
