# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    Option = Struct.new(:id, :name)

    # Checks if the resource should show its scope or not.
    # resource - the resource to analize
    #
    # Returns boolean.
    def has_visible_scopes?(resource)
      try(:current_participatory_space)&.try(:scopes_enabled?) && resource.scope.present? && current_participatory_space_scope&.id != resource.scope&.id
    end

    # Retrieves the translated name and type for an scope.
    # scope - a Decidim::Scope
    # global_name - text to use when scope is nil
    #
    # Returns a string
    def scope_name_for_picker(scope, global_name)
      if scope
        "#{translated_attribute(scope.name)} (#{translated_attribute(scope.scope_type.name)})"
      else
        global_name
      end
    end

    # Retrieves current participatory space scope (if this is Scopable or has the scope property).
    #
    # Returns a Decidim::Scope
    def current_participatory_space_scope
      @current_participatory_space_scope = try(:current_participatory_space)&.try(:scope) unless defined?(@current_participatory_space_scope)
      @current_participatory_space_scope
    end

    # Renders a scopes picker field in a form.
    # form - FormBuilder object
    # name - attribute name
    #
    # Returns nothing.
    def scopes_picker_field(form, name)
      form.scopes_picker name do |scope|
        { url: decidim.scopes_picker_path(root: current_participatory_space_scope, current: scope&.id, field: form.label_for(name)),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.global")) }
      end
    end

    # Renders a scopes picker field in a filter form.
    # form - FilterFormBuilder object
    # name - attribute name
    #
    # Returns nothing.
    def scopes_picker_filter(form, name)
      form.scopes_picker name, multiple: true, legend_title: I18n.t("decidim.scopes.scopes"), label: false do |scope|
        { url: decidim.scopes_picker_path(root: current_participatory_space_scope, current: scope&.id, title: I18n.t("decidim.scopes.prompt"), global_value: "global"),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt")) }
      end
    end
  end
end
