# frozen_string_literal: true

module Decidim
  module Admin
    module ImportsHelper
      def import_dropdown(component = current_component, resource_id = nil)
        render partial: "decidim/admin/imports/dropdown", locals: { component: component, resource_id: resource_id }
      end
    end
  end
end
