# frozen_string_literal: true

module Decidim
  module Admin
    module Components
      # This controller is the abstract class from which all component
      # controllers in their admin engines should inherit from.
      class BaseController < Admin::ApplicationController
        include Settings

        include Decidim::Admin::ParticipatorySpaceAdminContext
        include Decidim::NeedsPermission
        participatory_space_admin_layout

        helper Decidim::ResourceHelper
        helper Decidim::Admin::ExportsHelper
        helper Decidim::Admin::BulkActionsHelper

        helper_method :current_component,
                      :current_participatory_space,
                      :parent_path,
                      :edit_component_permissions_path

        before_action except: [:index, :show] do
          enforce_permission_to :manage, :component, component: current_component
        end

        before_action on: [:index, :show] do
          enforce_permission_to :read, :component, component: current_component
        end

        def permissions_context
          super.merge(participatory_space: current_participatory_space)
        end

        def permission_class_chain
          [
            current_component.manifest.permissions_class,
            current_participatory_space.manifest.permissions_class,
            Decidim::Admin::Permissions
          ]
        end

        def permission_scope
          :admin
        end

        def current_component
          request.env["decidim.current_component"]
        end

        def current_participatory_space
          current_component.participatory_space
        end

        def parent_path
          @parent_path ||= current_participatory_space_admin_proxy.components_path
        end

        def edit_component_permissions_path(resource)
          current_participatory_space_admin_proxy.edit_component_permissions_path(current_component.id, resource_name: resource.resource_manifest.name, resource_id: resource.id)
        end

        private

        def current_participatory_space_admin_proxy
          @current_participatory_space_admin_proxy ||= ::Decidim::EngineRouter.admin_proxy(current_participatory_space)
        end
      end
    end
  end
end
