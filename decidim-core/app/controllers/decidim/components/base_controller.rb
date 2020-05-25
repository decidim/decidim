# frozen_string_literal: true

module Decidim
  module Components
    # Controller from which all component engines inherit from. It's in charge of
    # setting the appropiate layout, including necessary helpers, and overall
    # fooling the engine into thinking it's isolated.
    class BaseController < Decidim::ApplicationController
      include Settings
      include Decidim::NeedsPermission

      include ParticipatorySpaceContext
      participatory_space_layout

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::ResourceVersionsHelper
      helper Decidim::TranslationsHelper
      helper Decidim::IconHelper
      helper Decidim::ResourceHelper
      helper Decidim::ScopesHelper
      helper Decidim::ActionAuthorizationHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PadHelper

      helper_method :current_component,
                    :current_participatory_space,
                    :current_manifest

      before_action do
        enforce_permission_to :read, :component, component: current_component
      end

      before_action :redirect_unless_feature_private

      def current_participatory_space
        request.env["decidim.current_participatory_space"]
      end

      def current_component
        request.env["decidim.current_component"]
      end

      def current_manifest
        @current_manifest ||= current_component.manifest
      end

      def permission_scope
        :public
      end

      def permission_class_chain
        [
          current_component.manifest.permissions_class,
          current_participatory_space.manifest.permissions_class,
          Decidim::Admin::Permissions,
          Decidim::Permissions
        ]
      end

      def redirect_unless_feature_private
        raise ActionController::RoutingError, "Not Found" unless current_user_can_visit_space?
      end

      def parent_component_context
        @parent_component_context ||= if parent_component
                                        parent_component.manifest.run_hooks(:parent_context,
                                                                            parent_component: parent_component,
                                                                            current_user: current_user).reduce({}, :merge)
                                      else
                                        {}
                                      end
      end

      def parent_component
        return @parent_component if defined?(@parent_component)

        @parent_component = if current_component.allow_children?
                              current_component
                            elsif current_component.allow_parent? && current_component.parent
                              current_component.parent
                            end
      end
    end
  end
end
