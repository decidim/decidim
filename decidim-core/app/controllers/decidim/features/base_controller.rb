# frozen_string_literal: true

module Decidim
  module Features
    # Controller from which all feature engines inherit from. It's in charge of
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

      helper_method :current_feature,
                    :current_participatory_space,
                    :current_manifest

      skip_authorize_resource

      before_action do
        authorize! :read, current_feature
      end
      before_action :redirect_unless_feature_private

      def current_participatory_space
        request.env["decidim.current_participatory_space"]
      end

      def current_feature
        request.env["decidim.current_feature"]
      end

      def current_manifest
        @current_manifest ||= current_feature.manifest
      end

      def ability_context
        super.merge(
          current_manifest: current_manifest,
          current_settings: current_settings,
          feature_settings: feature_settings
        )
      end

      def redirect_unless_feature_private
        redirect_to "/404" unless current_user_can_visit_space?
      end
    end
  end
end
