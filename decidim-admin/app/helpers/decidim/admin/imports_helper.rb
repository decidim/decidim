# frozen_string_literal: true

module Decidim
  module Admin
    module ImportsHelper
      # Renders an import dropdown for the provided component. Additional dropdown items
      # can be given as block.
      #
      # component - The component to render the export dropdown for. Defaults to the
      #           current component.
      #
      # resource_id - The resource id that is passed to route.
      #
      # Returns a rendered dropdown.
      def import_dropdown(component = current_component, resource_id = nil)
        locals = { component: component, resource_id: resource_id }
        locals[:block] = yield if block_given?
        render partial: "decidim/admin/imports/dropdown", locals: locals
      end

      # Routes to the correct importer for a component.
      #
      # component - The component to be routed.
      # options - Extra options that need to be passed to the route.
      #
      # Returns the path to the component importer.
      def admin_imports_path(component, options)
        EngineRouter.admin_proxy(component.participatory_space).new_component_import_path(options.merge(component_id: component))
      end

      # Public: A formatted collection of mime_type to be used in forms.
      def mime_types
        accepted_mime_types = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES.keys
        accepted_mime_types.map { |mime_type| t("decidim.admin.imports.new.accepted_mime_types.#{mime_type}") }.join(", ")
      end

      # Renders a user_group select field in a form.
      # form - FormBuilder object
      # name - attribute user_group_id
      #
      # Returns nothing.
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
