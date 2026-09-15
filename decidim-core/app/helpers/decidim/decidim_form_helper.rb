# frozen_string_literal: true

module Decidim
  # A helper to expose an easy way to add authorization forms in a view.
  module DecidimFormHelper
    # A custom form for that injects client side validations with Abide.
    #
    # record - The object to build the form for.
    # options - A Hash of options to pass to the form builder.
    # &block - The block to execute as content of the form.
    #
    # Returns a String.
    def decidim_form_for(record, options = {}, &)
      options = parse_html_options(options)

      # Generally called by form_for but we need the :url option generated
      # already before that.
      #
      # See:
      # https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/form_helper.rb#L459
      if record.is_a?(ActiveRecord::Base)
        object = record.is_a?(Array) ? record.last : record
        format = options[:format]
        apply_form_for_options!(object, options) if object
        options[:format] = format if format
      end

      output = ""
      output += base_error_messages(record).to_s
      output += form_for(record, options, &).to_s

      output.html_safe
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
    # Returns a rich editor to be included in an html template.
    def editor_field_tag(name, value, options = {})
      options[:toolbar] ||= "basic"
      options[:lines] ||= 10

      content_tag(:div, class: "editor") do
        template = ""
        template += label_tag(name, options[:label]) if options[:label] != false
        template += hidden_field_tag(name, value, options)
        template += content_tag(:div, nil, class: "editor-container", data: {
                                  toolbar: options[:toolbar], controller: "editor"
                                }, style: "height: #{options[:lines]}rem")
        template.html_safe
      end
    end

    # Helper method to show how slugs will look like. Intended to be used in forms
    # together with some JavaScript code. More precisely, this will most probably
    # show in help texts in forms. The space slug is surrounded with a `span` so
    # the slug can be updated via JavaScript with the input value.
    #
    # prepend_path - a path to prepend to the slug, without final slash
    # value - the initial value of the slug field, so that edit forms have a value
    #
    # Returns an HTML-safe String.
    def decidim_form_slug_url(prepend_path = "", value = "")
      prepend_slug_path = if prepend_path.present?
                            "/#{prepend_path}/"
                          else
                            "/"
                          end
      content_tag(:span, class: "slug-url") do
        [
          request.protocol,
          request.host_with_port,
          prepend_slug_path
        ].join.html_safe +
          content_tag(:span, value, class: "slug-url-value")
      end
    end

    # Helper method to show an explanation for the form's required fields that
    # are marked with an asterisk character. This improves the accessibility of
    # the forms.
    #
    # Returns an HTML-safe String.
    def form_required_explanation
      content_tag(:div, class: "help-text") do
        I18n.t("forms.required_explanation")
      end
    end

    def base_error_messages(record)
      return unless record.respond_to?(:errors)
      return unless record.errors[:base].any?

      alert_box(record.errors.full_messages_for(:base).join(","), :alert, false)
    end

    # Handle which collection to pass to Decidim::FilterFormBuilder.areas_select
    def areas_for_select(organization)
      return organization.areas if organization.area_types.blank?
      return organization.areas if organization.area_types.all? { |at| at.area_ids.empty? }

      organization.area_types
    end

    private

    def parse_html_options(options)
      options[:data] ||= {}
      options[:data].update(live_validate: true, validate_on_blur: true)
      options[:data].update(controller: "") unless options[:data].has_key?(:controller)
      options[:data][:controller] += " form-validator autofocus"
      options[:data][:controller].strip!

      options[:html] ||= {}
      options[:html].update(novalidate: true) unless options[:html].has_key?(:novalidate)

      options
    end
  end
end
