# frozen_string_literal: true

module Decidim
  module Admin
    # This module contains all the logic needed for a controller to render a participatory space
    # public layout. modqule ParticipatorySpaceAdminContext
    module ParticipatorySpaceAdminContext
      extend ActiveSupport::Concern

      class_methods do
        # Public: Called on a controller, it sets up all the surrounding methods to render a
        # participatory space's admin template. It expects the method `current_participatory_space`
        # to be defined, from which it will extract the participatory manifest.
        #
        # options - A hash used to modify the behavior of the layout. :only: - An array of actions
        #         on which the layout will be applied.
        #
        # Returns nothing.
        def participatory_space_admin_layout(options = {})
          layout :layout, options
          before_action :authorize_participatory_space, options
        end
      end

      included do
        include Decidim::NeedsOrganization
        helper ParticipatorySpaceHelpers

        helper_method :current_participatory_space
        helper_method :current_participatory_space_manifest
        helper_method :current_participatory_space_context

        before_action :space_is_active?

        def current_participatory_space_manifest_name
          nil
        end
      end

      private

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= 
          Decidim.find_participatory_space_manifest(current_participatory_space_manifest_name)
      end

      def current_participatory_space_context
        :admin
      end

      def current_participatory_space
        raise NotImplementedError
      end

      def authorize_participatory_space
        authorize! :read, current_participatory_space
      end

      def ability_context
        super.merge(
          current_participatory_space: current_participatory_space
        )
      end

      def layout
        current_participatory_space_manifest.context(current_participatory_space_context).layout
      end

      def space_is_active?
        return true if current_participatory_space_manifest.space_for(current_organization).active?

        raise ActionController::RoutingError.new("Space is not active")
      end
    end
  end
end
