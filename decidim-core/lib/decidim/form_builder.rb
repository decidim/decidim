# frozen_string_literal: true
require "foundation_rails_helper/form_builder"

module Decidim
  # This custom FormBuilder adds fields needed to deal with translatable fields,
  # following the conventions set on `Decidim::TranslatableAttributes`.
  class FormBuilder < FoundationRailsHelper::FormBuilder
    include ActionView::Context

    # Public: Generates an form field for each locale.
    #
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def translated(type, name, options = {})
      if locales.count == 1
        return send(
          type,
          "#{name}_#{locales.first.to_s.gsub("-", "__")}",
          options.merge(label: options[:label] || label_for(name))
        )
      end

      field_label = label_i18n(name, options[:label] || label_for(name))

      tabs_panels = "".html_safe
      if options[:label] != false
        tabs_panels = content_tag(:ul, class: "tabs", id: "#{name}-tabs", data: { tabs: true }) do
          locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
            string + content_tag(:li, class: tab_element_class_for("title", index)) do
              title = I18n.t(locale, scope: "locales")
              element_class = ""
              element_class += "alert" if has_error?(name_with_locale(name, locale))
              content_tag(:a, title, href: "##{name}-panel-#{index}", class: element_class)
            end
          end
        end
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: "#{name}-tabs" }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: "#{name}-panel-#{index}") do
            send(type, name_with_locale(name, locale), options.merge(label: false))
          end
        end
      end

      safe_join [field_label, tabs_panels, tabs_content]
    end

    # Public: generates a hidden field and a container for WYSIWYG editor
    #
    # name - The name of the field
    # options - The set of options to send to the field
    #           :label   - The Boolean value to create or not the input label (optional) (default: true)
    #           :toolbar - The String value to configure WYSIWYG toolbar. It should be 'basic' or
    #                      or 'full' (optional) (default: 'basic')
    #           :lines   - The Integer to indicate how many lines should editor have (optional) (default: 10)
    #
    # Renders a container with both hidden field and editor container
    def editor(name, options = {})
      options[:toolbar] ||= "basic"
      options[:lines] ||= 10

      content_tag(:div, class: "editor") do
        template = ""
        template += label(name) if options[:label] != false
        template += hidden_field(name, options)
        template += content_tag(:div, nil, class: "editor-container", data: {
                                  toolbar: options[:toolbar]
                                }, style: "height: #{options[:lines]}rem")
        template += error_for(name, options) if has_error?(name)
        template.html_safe
      end
    end

    # Public: Generates a select field with the categories. Only leaf categories can be set as selected.
    #
    # name       - The name of the field (usually category_id)
    # collection - A collection of categories.
    # options    - An optional Hash with options:
    # - prompt   - An optional String with the text to display as prompt.
    # - disable_parents - A Boolean to disable parent categories. Defaults to `true`.
    #
    # Returns a String.
    def categories_select(name, collection, options = {})
      options = {
        disable_parents: true
      }.merge(options)

      disable_parents = options[:disable_parents]

      selected = object.send(name)
      categories = categories_for_select(collection)
      disabled = if disable_parents
                   disabled_categories_for(collection)
                 else
                   []
                 end

      select(name, @template.options_for_select(categories, selected: selected, disabled: disabled), options)
    end

    private

    def categories_for_select(scope)
      sorted_main_categories = scope.first_class.includes(:subcategories).sort_by do |category|
        category.name[I18n.locale.to_s]
      end

      sorted_main_categories.flat_map do |category|
        parent = [[category.name[I18n.locale.to_s], category.id]]

        sorted_subcategories = category.subcategories.sort_by do |subcategory|
          subcategory.name[I18n.locale.to_s]
        end

        sorted_subcategories.each do |subcategory|
          parent << ["- #{subcategory.name[I18n.locale.to_s]}", subcategory.id]
        end

        parent
      end
    end

    def disabled_categories_for(scope)
      scope.first_class.joins(:subcategories).pluck(:id)
    end

    def tab_element_class_for(type, index)
      element_class = "tabs-#{type}"
      element_class += " is-active" if index.zero?
      element_class
    end

    def locales
      @locales ||= if @template.respond_to?(:available_locales)
                     Set.new([@template.current_locale] + @template.available_locales).to_a
                   else
                     Decidim.available_locales
                   end
    end

    def label_for(attribute)
      if object.class.respond_to?(:human_attribute_name)
        object.class.human_attribute_name(attribute)
      else
        attribute.to_s.humanize
      end
    end

    def name_with_locale(name, locale)
      "#{name}_#{locale.to_s.gsub("-", "__")}"
    end

    def label_i18n(attribute, text = nil, options = {})
      errored = has_error?(attribute) || locales.any? { |locale| has_error?(name_with_locale(attribute, locale)) }

      if errored
        options[:class] ||= ""
        options[:class] += " is-invalid-label"
      end

      label(attribute, (text || "").html_safe, options)
    end
  end
end
