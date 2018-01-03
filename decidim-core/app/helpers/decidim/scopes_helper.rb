# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    Option = Struct.new(:id, :name)

    # Check whether the resource has a visible scope or not.
    #
    # Returns boolean.
    def has_visible_scopes?(resource)
      current_participatory_space.scopes_enabled? && current_participatory_space.scope.blank? && resource.scope.present?
    end

    def scope_name_for_picker(scope, global_name)
      if scope
        "#{translated_attribute(scope.name)} (#{translated_attribute(scope.scope_type.name)})"
      else
        global_name
      end
    end

    def scopes_picker_field(form, name)
      form.scopes_picker name do |scope|
        { url: decidim.scopes_picker_path(root: try(:current_participatory_space)&.scope, current: scope&.id, field: form.label_for(name)),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.global")) }
      end
    end

    def scopes_picker_filter(form, name)
      form.scopes_picker name, multiple: true, legend_title: I18n.t("decidim.scopes.scopes"), label: false do |scope|
        { url: decidim.scopes_picker_path(root: try(:current_participatory_space)&.scope, current: scope&.id, title: I18n.t("decidim.scopes.prompt"), global_value: "global"),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt")) }
      end
    end
  end
end
