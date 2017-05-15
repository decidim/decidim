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

    # TODO
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

    # TODO
    def translated_field_tag(type, object_name, name, value = {}, options = {})
      locales = Decidim.available_locales

      tabs_id = "#{object_name}-#{name}-tabs"
      tabs_id = "#{options[:tabs_prefix]}-#{tabs_id}" if options[:tabs_prefix].present?

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
          tabs_panels = content_tag(:ul, class: "tabs tabs--lang", id: tabs_id, data: { tabs: true }) do
            locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
              string + content_tag(:li, class: tab_element_class_for("title", index)) do
                title = I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
                tab_content_id = "#{name}-panel-#{index}"
                tab_content_id = "#{options[:tabs_prefix]}-#{tab_content_id}" if options[:tabs_prefix].present?
                content_tag(:a, title, href: "##{tab_content_id}")
              end
            end
          end
        end

        safe_join [field_label, tabs_panels]
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          tab_content_id = "#{name}-panel-#{index}"
          tab_content_id = "#{options[:tabs_prefix]}-#{tab_content_id}" if options[:tabs_prefix].present?
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: tab_content_id) do
            send(type, "#{object_name}[#{name_with_locale(name, locale)}]", value[locale], options.merge(label: false))
          end
        end
      end

      safe_join [label_tabs, tabs_content]
    end

    def tab_element_class_for(type, index)
      element_class = "tabs-#{type}"
      element_class += " is-active" if index.zero?
      element_class
    end

    def name_with_locale(name, locale)
      "#{name}_#{locale.to_s.gsub("-", "__")}"
    end
  end
end
