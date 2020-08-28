# frozen_string_literal: true

require "foundation_rails_helper/form_builder"

module Decidim
  # This custom FormBuilder adds fields needed to deal with translatable fields,
  # following the conventions set on `Decidim::TranslatableAttributes`.
  class FormBuilder < FoundationRailsHelper::FormBuilder
    include ActionView::Context
    include Decidim::TranslatableAttributes

    # Public: generates a check boxes input from a collection and adds help
    # text and errors.
    #
    # attribute - the name of the field
    # collection - the collection from which we will render the check boxes
    # value_attribute - a Symbol or a Proc defining how to find the value
    #   attribute
    # text_attribute - a Symbol or a Proc defining how to find the text
    #   attribute
    # options - a Hash with options
    # html_options - a Hash with options
    #
    # Renders a collection of check boxes.
    # rubocop:disable Metrics/ParameterLists
    def collection_check_boxes(attribute, collection, value_attribute, text_attribute, options = {}, html_options = {})
      super + error_and_help_text(attribute, options)
    end
    # rubocop:enable Metrics/ParameterLists

    # Public: generates a radio buttons input from a collection and adds help
    # text and errors.
    #
    # attribute       - the name of the field
    # collection      - the collection from which we will render the radio buttons
    # value_attribute - a Symbol or a Proc defining how to find the value attribute
    # text_attribute  - a Symbol or a Proc defining how to find the text attribute
    # options         - a Hash with options
    # html_options    - a Hash with options
    #
    # Renders a collection of radio buttons.
    # rubocop:disable Metrics/ParameterLists
    def collection_radio_buttons(attribute, collection, value_attribute, text_attribute, options = {}, html_options = {})
      super + error_and_help_text(attribute, options)
    end
    # rubocop:enable Metrics/ParameterLists

    # Public: Generates an form field for each locale.
    #
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def translated(type, name, options = {})
      return translated_one_locale(type, name, locales.first, options.merge(label: (options[:label] || label_for(name)))) if locales.count == 1

      tabs_id = sanitize_tabs_selector(options[:tabs_id] || "#{object_name}-#{name}-tabs")

      label_tabs = content_tag(:div, class: "label--tabs") do
        field_label = label_i18n(name, options[:label] || label_for(name))

        tabs_panels = "".html_safe
        if options[:label] != false
          tabs_panels = content_tag(:ul, class: "tabs tabs--lang", id: tabs_id, data: { tabs: true }) do
            locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
              string + content_tag(:li, class: tab_element_class_for("title", index)) do
                title = I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
                element_class = nil
                element_class = "is-tab-error" if error?(name_with_locale(name, locale))
                tab_content_id = sanitize_tabs_selector "#{tabs_id}-#{name}-panel-#{index}"
                content_tag(:a, title, href: "##{tab_content_id}", class: element_class)
              end
            end
          end
        end

        safe_join [field_label, tabs_panels]
      end

      hashtaggable = options.delete(:hashtaggable)
      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          tab_content_id = "#{tabs_id}-#{name}-panel-#{index}"
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: tab_content_id) do
            if hashtaggable
              hashtaggable_text_field(type, name, locale, options.merge(label: false))
            elsif type.to_sym == :editor
              send(type, name_with_locale(name, locale), options.merge(label: false, hashtaggable: hashtaggable))
            else
              send(type, name_with_locale(name, locale), options.merge(label: false))
            end
          end
        end
      end

      safe_join [label_tabs, tabs_content]
    end

    def translated_one_locale(type, name, locale, options = {})
      return hashtaggable_text_field(type, name, locale, options) if options.delete(:hashtaggable)

      send(
        type,
        "#{name}_#{locale.to_s.gsub("-", "__")}",
        options.merge(label: options[:label] || label_for(name))
      )
    end

    # Public: Generates a field for hashtaggable type.
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # handlers - The social handlers to be created
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def hashtaggable_text_field(type, name, locale, options = {})
      options[:hashtaggable] = true if type.to_sym == :editor

      content_tag(:div, class: "hashtags__container") do
        if options[:value]
          send(type, name_with_locale(name, locale), options.merge(label: options[:label], value: options[:value][locale]))
        else
          send(type, name_with_locale(name, locale), options.merge(label: options[:label]))
        end
      end
    end

    # Public: Generates an form field for each social.
    #
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # handlers - The social handlers to be created
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def social_field(type, name, handlers, options = {})
      tabs_id = sanitize_tabs_selector(options[:tabs_id] || "#{object_name}-#{name}-tabs")

      label_tabs = content_tag(:div, class: "label--tabs") do
        field_label = label_i18n(name, options[:label] || label_for(name))

        tabs_panels = "".html_safe
        if options[:label] != false
          tabs_panels = content_tag(:ul, class: "tabs tabs--lang", id: tabs_id, data: { tabs: true }) do
            handlers.each_with_index.inject("".html_safe) do |string, (handler, index)|
              string + content_tag(:li, class: tab_element_class_for("title", index)) do
                title = I18n.t(".#{handler}", scope: "activemodel.attributes.#{object_name}")
                tab_content_id = sanitize_tabs_selector "#{tabs_id}-#{name}-panel-#{index}"
                content_tag(:a, title, href: "##{tab_content_id}")
              end
            end
          end
        end

        safe_join [field_label, tabs_panels]
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
        handlers.each_with_index.inject("".html_safe) do |string, (handler, index)|
          tab_content_id = sanitize_tabs_selector "#{tabs_id}-#{name}-panel-#{index}"
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: tab_content_id) do
            send(type, "#{handler}_handler", options.merge(label: false))
          end
        end
      end

      safe_join [label_tabs, tabs_content]
    end

    # Public: generates a hidden field and a container for WYSIWYG editor
    #
    # name - The name of the field
    # options - The set of options to send to the field
    #           :label - The Boolean value to create or not the input label (optional) (default: true)
    #           :toolbar - The String value to configure WYSIWYG toolbar. It should be 'basic' or
    #                      or 'full' (optional) (default: 'basic')
    #           :lines - The Integer to indicate how many lines should editor have (optional) (default: 10)
    #           :disabled - Whether the editor should be disabled
    #
    # Renders a container with both hidden field and editor container
    def editor(name, options = {})
      options[:disabled] ||= false
      toolbar = options.delete(:toolbar) || "basic"
      lines = options.delete(:lines) || 10
      label_text = options[:label].to_s
      label_text = label_for(name) if label_text.blank?
      options.delete(:required)
      hashtaggable = options.delete(:hashtaggable)
      hidden_options = extract_validations(name, options).merge(options)

      content_tag(:div, class: "editor #{"hashtags__container" if hashtaggable}") do
        template = ""
        template += label(name, label_text + required_for_attribute(name)) if options.fetch(:label, true)
        template += hidden_field(name, hidden_options)
        template += content_tag(:div, nil, class: "editor-container #{"js-hashtags" if hashtaggable}", data: {
                                  toolbar: toolbar,
                                  disabled: options[:disabled]
                                }, style: "height: #{lines}rem")
        template += error_for(name, options) if error?(name)
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
    # html_options - HTML options for the select
    #
    # Returns a String.
    def categories_select(name, collection, options = {}, html_options = {})
      options = {
        disable_parents: true
      }.merge(options)

      disable_parents = options[:disable_parents]

      selected = object.send(name)
      selected = selected.first if selected.is_a?(Array) && selected.length > 1
      categories = categories_for_select(collection)
      disabled = if disable_parents
                   disabled_categories_for(collection)
                 else
                   []
                 end

      select(name, @template.options_for_select(categories, selected: selected, disabled: disabled), options, html_options)
    end

    # Public: Generates a select field for areas.
    #
    # name       - The name of the field (usually area_id)
    # collection - A collection of areas or area_types.
    #              If it's areas, we sort the selectable options alphabetically.
    #
    # Returns a String.
    def areas_select(name, collection, options = {}, html_options = {})
      selectables = if collection.first.is_a?(Decidim::Area)
                      assemblies = collection
                                   .map { |a| [a.name[I18n.locale.to_s], a.id] }
                                   .sort_by { |arr| arr[0] }

                      @template.options_for_select(
                        assemblies,
                        selected: options[:selected]
                      )
                    else
                      @template.option_groups_from_collection_for_select(
                        collection,
                        :areas,
                        :translated_name,
                        :id,
                        :translated_name,
                        selected: options[:selected]
                      )
                    end

      select(name, selectables, options, html_options)
    end

    # Public: Generates a select field for resource types.
    #
    # name       - The name of the field (usually resource_type)
    # collection - A collection of resource types.
    #              The options are sorted alphabetically.
    #
    # Returns a String.
    def resources_select(name, collection, options = {})
      resources =
        collection
        .map { |r| [I18n.t(r.split("::").last.underscore, scope: "decidim.components.component_order_selector.order"), r] }
        .sort

      select(name, @template.options_for_select(resources, selected: options[:selected]), options)
    end

    # Public: Generates a picker field for scope selection.
    #
    # attribute     - The name of the field (usually scope_id)
    # options       - An optional Hash with options:
    # - multiple    - Multiple mode, to allow multiple scopes selection.
    # - label       - Show label?
    # - checkboxes_on_top - Show checked picker values on top (default) or below the picker prompt (only for multiple pickers)
    #
    # Also it should receive a block that returns a Hash with :url and :text for each selected scope (and for null scope for prompt)
    #
    # Returns a String.
    def scopes_picker(attribute, options = {})
      id = if self.options.has_key?(:namespace)
             "#{self.options[:namespace]}_#{id}"
           else
             "#{sanitize_for_dom_selector(@object_name)}_#{attribute}"
           end

      picker_options = {
        id: id,
        class: "picker-#{options[:multiple] ? "multiple" : "single"}",
        name: "#{@object_name}[#{attribute}]"
      }

      picker_options[:class] += " is-invalid-input" if error?(attribute)

      prompt_params = yield(nil)
      scopes = selected_scopes(attribute).map { |scope| [scope, yield(scope)] }
      template = ""
      template += "<label>#{label_for(attribute) + required_for_attribute(attribute)}</label>" unless options[:label] == false
      template += @template.render("decidim/scopes/scopes_picker_input",
                                   picker_options: picker_options,
                                   prompt_params: prompt_params,
                                   scopes: scopes,
                                   values_on_top: !options[:multiple] || options[:checkboxes_on_top])
      template += error_and_help_text(attribute, options)
      template.html_safe
    end

    # Public: Generates a picker field for selection (either simple or multiselect).
    #
    # attribute     - The name of the object's attribute.
    # options       - A Hash with options:
    # - multiple: Multiple mode, to allow selection of multiple items.
    # - label: Show label?
    # - name: (optional) The name attribute of the input elements.
    # prompt_params - Hash with options:
    # - url: The url where the ajax endpoint that will fill the content of the selector popup (the prompt).
    # - text: Text in the button to open the Data Picker selector.
    #
    # Also it should receive a block that returns a Hash with :url and :text for each selected scope
    #
    # Returns an html String.
    def data_picker(attribute, options = {}, prompt_params = {})
      picker_options = {
        id: "#{@object_name}_#{attribute}",
        class: "picker-#{options[:multiple] ? "multiple" : "single"}",
        name: options[:name] || "#{@object_name}[#{attribute}]"
      }
      picker_options[:class] += " is-invalid-input" if error?(attribute)
      picker_options[:class] += " picker-autosort" if options[:autosort]

      items = object.send(attribute).collect { |item| [item, yield(item)] }

      template = ""
      template += label(attribute, label_for(attribute) + required_for_attribute(attribute)) unless options[:label] == false
      template += @template.render("decidim/widgets/data_picker", picker_options: picker_options, prompt_params: prompt_params, items: items)
      template += error_and_help_text(attribute, options)
      template.html_safe
    end

    # Public: Override so checkboxes are rendered before the label.
    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      custom_label(attribute, options[:label], options[:label_options], true) do
        options.delete(:label)
        options.delete(:label_options)
        @template.check_box(@object_name, attribute, objectify_options(options), checked_value, unchecked_value)
      end + error_and_help_text(attribute, options)
    end

    # Public: Override so the date fields are rendered using foundation
    # datepicker library
    def date_field(attribute, options = {})
      value = object.send(attribute)
      data = { datepicker: "" }
      data[:startdate] = I18n.localize(value, format: :decidim_short) if value.present? && value.is_a?(Date)
      datepicker_format = ruby_format_to_datepicker(I18n.t("date.formats.decidim_short"))
      data[:"date-format"] = datepicker_format

      template = text_field(
        attribute,
        options.merge(data: data)
      )
      help_text = I18n.t("decidim.datepicker.help_text", datepicker_format: datepicker_format)
      template += error_and_help_text(attribute, options.merge(help_text: help_text))
      template.html_safe
    end

    # Public: Generates a timepicker field using foundation
    # datepicker library
    def datetime_field(attribute, options = {})
      value = object.send(attribute)
      data = { datepicker: "", timepicker: "" }
      data[:startdate] = I18n.localize(value, format: :decidim_short) if value.present? && value.is_a?(ActiveSupport::TimeWithZone)
      datepicker_format = ruby_format_to_datepicker(I18n.t("time.formats.decidim_short"))
      data[:"date-format"] = datepicker_format

      template = text_field(
        attribute,
        options.merge(data: data)
      )
      help_text = I18n.t("decidim.datepicker.help_text", datepicker_format: datepicker_format)
      template += error_and_help_text(attribute, options.merge(help_text: help_text))
      template.html_safe
    end

    # Public: Generates a file upload field and sets the form as multipart.
    # If the file is an image it displays the default image if present or the current one.
    # By default it also generates a checkbox to delete the file. This checkbox can
    # be hidden if `options[:optional]` is passed as `false`.
    #
    # attribute    - The String name of the attribute to buidl the field.
    # options      - A Hash with options to build the field.
    #              * optional: Whether the file can be optional or not.
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def upload(attribute, options = {})
      self.multipart = true
      options[:optional] = options[:optional].nil? ? true : options[:optional]
      alt_text = label_for(attribute)

      file = object.send attribute
      template = ""
      template += label(attribute, label_for(attribute) + required_for_attribute(attribute))
      template += upload_help(attribute, options)
      template += @template.file_field @object_name, attribute

      template += extension_whitelist_help(options[:extension_whitelist]) if options[:extension_whitelist].present?
      template += image_dimensions_help(options[:dimensions_info]) if options[:dimensions_info].present?

      if file_is_image?(file)
        template += if file.present?
                      @template.content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                    else
                      @template.content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                    end
        template += @template.link_to @template.image_tag(file.url, alt: alt_text), file.url, target: "_blank", rel: "noopener"
      elsif file_is_present?(file)
        template += @template.label_tag I18n.t("current_file", scope: "decidim.forms")
        template += @template.link_to file.file.filename, file.url, target: "_blank", rel: "noopener"
      end

      if file_is_present?(file)
        if options[:optional]
          template += content_tag :div, class: "field" do
            safe_join([
                        @template.check_box(@object_name, "remove_#{attribute}"),
                        label("remove_#{attribute}", I18n.t("remove_this_file", scope: "decidim.forms"))
                      ])
          end
        end
      end

      if object.errors[attribute].any?
        template += content_tag :p, class: "is-invalid-label" do
          safe_join object.errors[attribute], "<br/>".html_safe
        end
      end

      template.html_safe
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def upload_help(attribute, _options = {})
      file = object.send attribute

      content_tag(:div, class: "help-text") do
        file_size_validator = object.singleton_class.validators_on(
          attribute
        ).find { |validator| validator.is_a?(::ActiveModel::Validations::FileSizeValidator) }
        if file_size_validator
          lte = file_size_validator.options[:less_than_or_equal_to]
          max_file_size = lte.call(nil) if lte && lte.lambda?
        end

        help_scope = begin
          if file.is_a?(Decidim::ImageUploader)
            "decidim.forms.file_help.image"
          else
            "decidim.forms.file_help.file"
          end
        end
        help_messages = %w(message_1 message_2)

        inner = "<p>#{I18n.t("explanation", scope: help_scope)}</p>".html_safe
        inner + content_tag(:ul) do
          messages = help_messages.each.map { |msg| I18n.t(msg, scope: help_scope) }

          if max_file_size
            file_size_mb = (((max_file_size / 1024 / 1024) * 100) / 100).round
            messages << I18n.t(
              "max_file_size",
              megabytes: file_size_mb,
              scope: "decidim.forms.file_validation"
            )
          end

          if file.respond_to?(:extension_whitelist, true)
            allowed_extensions = file.send(:extension_whitelist)
            messages << I18n.t(
              "allowed_file_extensions",
              extensions: allowed_extensions.join(" "),
              scope: "decidim.forms.file_validation"
            )
          end

          messages.map { |msg| content_tag(:li, msg) }.join("\n").html_safe
        end.html_safe
      end
    end

    # Public: Returns the translated name for the given attribute.
    #
    # attribute    - The String name of the attribute to return the name.
    def label_for(attribute)
      if object.class.respond_to?(:human_attribute_name)
        object.class.human_attribute_name(attribute)
      else
        attribute.to_s.humanize
      end
    end

    def form_field_for(attribute, options = {})
      if attribute == :body
        text_area(attribute, options.merge(rows: 10))
      else
        text_field(attribute, options)
      end
    end

    # Discard the pattern attribute which is not allowed for textarea elements.
    def text_area(attribute, options = {})
      field(attribute, options) do |opts|
        opts.delete(:pattern)
        @template.send(
          :text_area,
          @object_name,
          attribute,
          objectify_options(opts)
        )
      end
    end

    private

    # Private: Override from FoundationRailsHelper in order to render
    # inputs inside the label and to automatically inject validations
    # from the object.
    #
    # attribute    - The String name of the attribute to buidl the field.
    # options      - A Hash with options to build the field.
    # html_options - An optional Hash with options to pass to the html element.
    #
    # Returns a String
    def field(attribute, options, html_options = nil, &block)
      label = options.delete(:label)
      label_options = options.delete(:label_options)
      custom_label(attribute, label, label_options) do
        field_with_validations(attribute, options, html_options, &block)
      end
    end

    # Private: Builds a form field and detects validations from
    # the form object.
    #
    # attribute    - The String name of the attribute to build the field.
    # options      - A Hash with options to build the field.
    # html_options - An optional Hash with options to pass to the html element.
    #
    # Returns a String.
    def field_with_validations(attribute, options, html_options)
      class_options = html_options || options

      if error?(attribute)
        class_options[:class] = class_options[:class].to_s
        class_options[:class] += " is-invalid-input"
      end

      help_text = options.delete(:help_text)
      prefix = options.delete(:prefix)
      postfix = options.delete(:postfix)

      class_options = extract_validations(attribute, options).merge(class_options)

      content = yield(class_options)
      content += abide_error_element(attribute) if class_options[:pattern] || class_options[:required]
      content = content.html_safe

      html = wrap_prefix_and_postfix(content, prefix, postfix)
      html + error_and_help_text(attribute, options.merge(help_text: help_text))
    end

    # Private: Builds a Hash of options to be injected at the HTML output as
    # HTML5 validations.
    #
    # attribute - The String name of the attribute to extract the validations.
    # options - A Hash of options to extract validations.
    #
    # Returns a Hash.
    def extract_validations(attribute, options)
      min_length = options.delete(:minlength) || length_for_attribute(attribute, :minimum) || 0
      max_length = options.delete(:maxlength) || length_for_attribute(attribute, :maximum)

      validation_options = {}
      validation_options[:pattern] = "^(.|[\n\r]){#{min_length},#{max_length}}$" if min_length.to_i.positive? || max_length.to_i.positive?
      validation_options[:required] = options[:required] || attribute_required?(attribute)
      validation_options[:minlength] ||= min_length if min_length.to_i.positive?
      validation_options[:maxlength] ||= max_length if max_length.to_i.positive?
      validation_options
    end

    # Private: Tries to find if an attribute is required in the form object.
    #
    # Returns Boolean.
    def attribute_required?(attribute)
      validator = find_validator(attribute, ActiveModel::Validations::PresenceValidator) ||
                  find_validator(attribute, TranslatablePresenceValidator)

      return unless validator

      # Check if the if condition is present and it evaluates to true
      if_condition = validator.options[:if]
      validator_if_condition = if_condition.nil? ||
                               (string_or_symbol?(if_condition) ? object.send(if_condition) : if_condition.call(object))

      # Check if the unless condition is present and it evaluates to false
      unless_condition = validator.options[:unless]
      validator_unless_condition = unless_condition.nil? ||
                                   (string_or_symbol?(unless_condition) ? !object.send(unless_condition) : !unless_condition.call(object))

      validator_if_condition && validator_unless_condition
    end

    def string_or_symbol?(obj)
      obj.is_a?(String) || obj.is_a?(Symbol)
    end

    # Private: Tries to find a length validator in the form object.
    #
    # attribute - The attribute to look for the validations.
    # type      - A Symbol for the type of length to fetch. Currently only :minimum & :maximum are supported.
    #
    # Returns an Integer or Nil.
    def length_for_attribute(attribute, type)
      length_validator = find_validator(attribute, ActiveModel::Validations::LengthValidator)
      return length_validator.options[type] if length_validator

      length_validator = find_validator(attribute, ProposalLengthValidator)
      if length_validator
        length = length_validator.options[type]
        return length.call(object) if length.respond_to?(:call)

        return length
      end

      nil
    end

    # Private: Finds a validator.
    #
    # attribute - The attribute to validate.
    # klass     - The Class of the validator to find.
    #
    # Returns a klass object.
    def find_validator(attribute, klass)
      return unless object.respond_to?(:_validators)

      object._validators[attribute.to_sym].find { |validator| validator.class == klass }
    end

    # Private: Override method from FoundationRailsHelper to render the text of the
    # label before the input, instead of after.
    #
    # attribute - The String name of the attribute we're build the label.
    # text      - The String text to use as label.
    # options   - A Hash to build the label.
    #
    # Returns a String.
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def custom_label(attribute, text, options, field_before_label = false, show_required = true)
      return block_given? ? yield.html_safe : "".html_safe if text == false

      text = default_label_text(object, attribute) if text.nil? || text == true
      text += required_for_attribute(attribute) if show_required

      text = if field_before_label && block_given?
               safe_join([yield, text.html_safe])
             elsif block_given?
               safe_join([text.html_safe, yield])
             end

      label(attribute, text, options || {})
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    # Private: Builds a span to be shown when there's a validation error in a field.
    # It looks for the text that will be the content in a similar way `human_attribute_name`
    # does it.
    #
    # attribute - The name of the attribute of the field.
    #
    # Returns a String.
    def abide_error_element(attribute)
      defaults = []
      defaults << :"decidim.forms.errors.#{object.class.model_name.i18n_key}.#{attribute}"
      defaults << :"decidim.forms.errors.#{attribute}"
      defaults << :"forms.errors.#{attribute}"
      defaults << :"decidim.forms.errors.error"

      options = { count: 1, default: defaults }

      text = I18n.t(defaults.shift, options)
      content_tag(:span, text, class: "form-error")
    end

    def categories_for_select(scope)
      sorted_main_categories = scope.first_class.includes(:subcategories).sort_by do |category|
        [category.weight, translated_attribute(category.name, category.participatory_space.organization)]
      end

      sorted_main_categories.flat_map do |category|
        parent = [[translated_attribute(category.name, category.participatory_space.organization), category.id]]

        sorted_subcategories = category.subcategories.sort_by do |subcategory|
          [subcategory.weight, translated_attribute(subcategory.name, subcategory.participatory_space.organization)]
        end

        sorted_subcategories.each do |subcategory|
          parent << ["- #{translated_attribute(subcategory.name, subcategory.participatory_space.organization)}", subcategory.id]
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

    def name_with_locale(name, locale)
      "#{name}_#{locale.to_s.gsub("-", "__")}"
    end

    def label_i18n(attribute, text = nil, options = {})
      errored = error?(attribute) || locales.any? { |locale| error?(name_with_locale(attribute, locale)) }

      if errored
        options[:class] ||= ""
        options[:class] += " is-invalid-label"
      end
      text += required_for_attribute(attribute)

      label(attribute, (text || "").html_safe, options)
    end

    # Private: Returns whether the file is an image or not.
    def file_is_image?(file)
      return unless file && file.respond_to?(:url)
      return file.content_type.start_with? "image" if file.content_type.present?

      Mime::Type.lookup_by_extension(File.extname(file.url)[1..-1]).to_s.start_with? "image" if file.url.present?
    end

    # Private: Returns whether the file exists or not.
    def file_is_present?(file)
      return unless file && file.respond_to?(:url)

      file.present?
    end

    def required_for_attribute(attribute)
      if attribute_required?(attribute)
        visible_title = content_tag(:span, "*", "aria-hidden": true)
        screenreader_title = content_tag(
          :span,
          I18n.t("required", scope: "forms"),
          class: "show-for-sr"
        )
        return content_tag(
          :span,
          visible_title + screenreader_title,
          title: I18n.t("required", scope: "forms"),
          data: { tooltip: true, disable_hover: false, keep_on_hover: true },
          "aria-haspopup": true,
          class: "label-required"
        ).html_safe
      end
      "".html_safe
    end

    # Private: Returns an array of scopes related to object attribute
    def selected_scopes(attribute)
      selected = object.send(attribute) || []
      selected = selected.values if selected.is_a?(Hash)
      selected = [selected] unless selected.is_a?(Array)
      selected = Decidim::Scope.where(id: selected.map(&:to_i)) unless selected.first.is_a?(Decidim::Scope)
      selected
    end

    # Private: Returns the help text and error tags at the end of the field.
    # Modified to change the tag to a valid HTML tag inside the <label> element.
    def error_and_help_text(attribute, options = {})
      html = ""
      html += content_tag(:span, options[:help_text], class: "help-text") if options[:help_text]
      html += error_for(attribute, options) || ""
      html.html_safe
    end

    def ruby_format_to_datepicker(ruby_date_format)
      ruby_date_format.gsub("%d", "dd").gsub("%m", "mm").gsub("%Y", "yyyy").gsub("%H", "hh").gsub("%M", "ii")
    end

    def sanitize_tabs_selector(id)
      id.tr("[", "-").tr("]", "-")
    end

    def sanitize_for_dom_selector(name)
      name.to_s.parameterize.underscore
    end

    def extension_whitelist_help(extension_whitelist)
      content_tag :p, class: "extensions-help help-text" do
        safe_join([
                    content_tag(:span, I18n.t("extension_whitelist", scope: "decidim.forms.files")),
                    " ",
                    safe_join(extension_whitelist.map { |ext| content_tag(:b, ext) }, ", ")
                  ])
      end
    end

    def image_dimensions_help(dimensions_info)
      content_tag :p, class: "image-dimensions-help help-text" do
        safe_join([
                    content_tag(:span, I18n.t("dimensions_info", scope: "decidim.forms.images")),
                    " ",
                    content_tag(:span) do
                      safe_join(dimensions_info.map do |_version, info|
                        processor = @template.content_tag(:span, I18n.t("processors.#{info[:processor]}", scope: "decidim.forms.images"))
                        dimensions = @template.content_tag(:b, I18n.t("dimensions", scope: "decidim.forms.images", width: info[:dimensions].first, height: info[:dimensions].last))
                        safe_join([processor, "  ", dimensions, ". ".html_safe])
                      end)
                    end
                  ])
      end
    end

    # Private: Creates a tag from the given options for the field prefix and
    # suffix. Overridden from Foundation Rails helper to make the generated HTML
    # valid since these elements are printed within <label> elements and <div>'s
    # are not allowed there.
    def tag_from_options(name, options)
      return "".html_safe unless options && options[:value].present?

      content_tag(:span,
                  content_tag(:span, options[:value], class: name),
                  class: column_classes(options).to_s)
    end

    # Private: Wraps the prefix and postfix for the field. Overridden from
    # Foundation Rails helper to make the generated HTML valid since these
    # elements are printed within <label> elements and <div>'s are not allowed
    # there.
    def wrap_prefix_and_postfix(block, prefix_options, postfix_options)
      prefix = tag_from_options("prefix", prefix_options)
      postfix = tag_from_options("postfix", postfix_options)

      input_size = calculate_input_size(prefix_options, postfix_options)
      klass = column_classes(input_size.marshal_dump).to_s
      input = content_tag(:span, block, class: klass)

      return block unless input_size.changed?

      content_tag(:span, prefix + input + postfix, class: "row collapse")
    end
  end
end
