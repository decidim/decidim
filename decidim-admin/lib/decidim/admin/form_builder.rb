# frozen_string_literal: true

module Decidim
  module Admin
    # This custom FormBuilder extends the FormBuilder present in core with
    # fields only used in admin.
    class FormBuilder < Decidim::FormBuilder
      # Generates a select field with autocompletion using ajax
      #
      # @param [Symbol] attribute
      #   The name of the object's attribute (usually something like user_id)
      # @param [Object] selected
      #   An instance of the selected value
      # @param [Hash] options
      #   A optional set of options to render the field:
      #   - :label (boolean|string) (optional) You can disable the creation of the input label passing false,
      #       or override the default label passing a string (default: name of the input)
      #   - :name (string) You can provide a custom name for the field to be submitted
      #   - :class (string) You can provide custom class name for the container (ex. autocomplete-field--results-inline)
      # @param [Hash] prompt_options
      #   Prompt configuration. A hash with options:
      #   - :url (String) The url where the ajax endpoint to fill the select
      #   - :placeholder (String) Text to use as placeholder
      #   - :no_results (String) (optional) Text to use when there are no matching results (default: No results found)
      #   - :search_prompt (String) (optional) Text to prompt for search input (default: Type at least three characters to search)
      #
      # @yield [resource]
      #   It should receive a block that returns a Hash for the selected option with:
      #   - value: This will be the value of the option select.
      #   - label: This will be the label of the option select.
      #
      # @example How to use it
      #   <% prompt_options = { url: users_url, text: t(".select_user") }
      #      options = { label: t(".user") } %>
      #   <%= form.autocomplete_select(:user_id, form.object.user.presence, options, prompt_options) do |user|
      #      { value: user.id, label: "#{user.name} (#{user.nickname})" }
      #    end %>
      #
      # @return [String]
      #   The HTML ready to output in the view
      #
      def autocomplete_select(attribute, selected = nil, options = {}, prompt_options = {})
        selected = yield(selected) if selected
        template = ""
        template += label(attribute, (options[:label] || label_for(attribute)) + required_for_attribute(attribute)) unless options[:label] == false
        template += content_tag(:div, nil, class: options[:class], data: {
                                  autocomplete: {
                                    name: options[:name] || "#{@object_name}[#{attribute}]",
                                    options: (options[:default_options].to_a + [selected]).compact,
                                    placeholder: prompt_options[:placeholder],
                                    searchURL: prompt_options[:url],
                                    changeURL: prompt_options[:change_url],
                                    selected: selected ? selected[:value] : "",
                                    searchPromptText: options[:search_prompt] || I18n.t("autocomplete.search_prompt", scope: "decidim.admin"),
                                    noResultsText: options[:no_results] || I18n.t("autocomplete.no_results", scope: "decidim.admin")
                                  },
                                  autocomplete_for: attribute,
                                  plugin: "autocomplete"
                                })
        template += error_for(attribute, options) if error?(attribute)
        template.html_safe
      end

      # Calls Decidim::FormBuilder#editor with default options for admin.
      def editor(name, options = {})
        super(
          name,
          {
            toolbar: :full,
            lines: 8
          }.merge(options)
        )
      end
    end
  end
end
