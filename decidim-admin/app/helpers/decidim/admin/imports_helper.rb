# frozen_string_literal: true

module Decidim
  module Admin
    module ImportsHelper
      def import_dropdown(component = current_component, resource_id = nil)
        render partial: "decidim/admin/imports/dropdown", locals: { component: component, resource_id: resource_id }
      end

      def admin_imports_path(component, options)
        EngineRouter.admin_proxy(component.participatory_space).new_component_imports_path(options.merge(component_id: component))
      end

      def mime_types
        types = ""
        accepted_mime_types = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES.keys
        accepted_mime_types.each_with_index do |mime_type, index|
          types += t(".accepted_mime_types.#{mime_type}")
          types += ", " unless accepted_mime_types.length == index + 1
        end
        types
      end

      def user_group_select_field(form, name)
        selected = @import.user_group_id.presence
        user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        form.select(
          name,
          user_groups.map { |g| [g.name, g.id] },
          selected: selected,
          include_blank: current_user.name
        )
      end
    end
  end
end
