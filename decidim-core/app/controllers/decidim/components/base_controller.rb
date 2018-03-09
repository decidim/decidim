# frozen_string_literal: true

module Decidim
  module Components
    # Controller from which all component engines inherit from. It's in charge of
    # setting the appropiate layout, including necessary helpers, and overall
    # fooling the engine into thinking it's isolated.
    class BaseController < Decidim::ApplicationController
      include Settings
      include ActionAuthorization

      include ParticipatorySpaceContext
      participatory_space_layout

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::TranslationsHelper
      helper Decidim::IconHelper
      helper Decidim::ResourceHelper
      helper Decidim::ScopesHelper
      helper Decidim::ActionAuthorizationHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper

      helper_method :current_component,
                    :current_participatory_space,
                    :current_manifest

      skip_authorize_resource

      before_action do
        authorize! :read, current_component
      end

      def current_participatory_space
        request.env["decidim.current_participatory_space"]
      end

      deprecate current_feature: "current_feature is deprecated and will be removed from Decidim's next release"

      def current_component
        request.env["decidim.current_component"]
      end
      alias current_feature current_component

      def current_manifest
        @current_manifest ||= current_component.manifest
      end

      def ability_context
        super.merge(
          current_manifest: current_manifest,
          current_settings: current_settings,
          component_settings: component_settings
        )
      end
    end
  end
end
