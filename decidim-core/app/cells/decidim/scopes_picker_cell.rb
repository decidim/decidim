# frozen_string_literal: true

module Decidim
  # This cell is used to display scopes picker in a form
  class ScopesPickerCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::FormOptionsHelper
    include Decidim::FiltersHelper
    include Decidim::ScopesHelper

    def form
      model
    end

    def checkboxes_on_top?
      options[:checkboxes_on_top]
    end

    def multiple?
      options[:multiple]
    end

    def values_on_top?
      !multiple? || checkboxes_on_top?
    end

    def legend_title
      options[:legend_title]
    end

    def label?
      options[:label]
    end

    def scope_params(scope)
      {
        url: decidim.scopes_picker_path(
          root: try(:current_participatory_space).try(:scope),
          current: scope&.id,
          title: I18n.t("decidim.scopes.prompt"),
          global_value: "global",
          max_depth: try(:current_participatory_space).try(:scope_type_max_depth)
        ),
        text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt"))
      }
    end

    def scopes
      selected_scopes.map { |scope| [scope, scope_params(scope)] }
    end

    def prompt_params
      scope_params(nil)
    end

    def attribute
      options[:attribute]
    end

    def picker_options_id
      if form.options.has_key?(:namespace)
        "#{form.options[:namespace]}_#{sanitize_for_dom_selector(form.object_name)}"
      else
        "#{sanitize_for_dom_selector(form.object_name)}_#{attribute}"
      end
    end

    def wrapper_class
      "#{attribute}_scopes_picker_filter"
    end

    def picker_options_class
      "picker-#{multiple? ? "multiple" : "single"}"
    end

    def picker_options_name
      "#{form.object_name}[#{attribute}]"
    end

    def sanitize_for_dom_selector(name)
      name.to_s.parameterize.underscore
    end

    def selected_scopes
      selected = form.object.send(attribute) || []
      selected = selected.values if selected.is_a?(Hash)
      selected = [selected] unless selected.is_a?(Array)
      selected = Decidim::Scope.where(id: selected.map(&:to_i)) unless selected.first.is_a?(Decidim::Scope)
      selected
    end
  end
end
