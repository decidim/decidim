# frozen_string_literal: true

module Decidim
  module Admin
    module ImportsHelper
      def import_dropdown(component = current_component, resource_id = nil)
        render partial: "decidim/admin/imports/dropdown", locals: { component: component, resource_id: resource_id }
      end

      def admin_imports_path(component, options)
        EngineRouter.admin_proxy(component.participatory_space).component_imports_path(options.merge(component_id: component))
      end
    end
  end
end
