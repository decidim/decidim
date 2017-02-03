# frozen_string_literal: true

module Decidim
  module Features
    # Controller from which all feature engines inherit from. It's in charge of
    # setting the appropiate layout, including necessary helpers, and overall
    # fooling the engine into thinking it's isolated.
    class BaseController < Decidim::ApplicationController
      layout "layouts/decidim/participatory_process"
      include NeedsParticipatoryProcess
      include FeatureSettings
      include ActionAuthorization

      helper Decidim::TranslationsHelper
      helper Decidim::ParticipatoryProcessHelper
      helper Decidim::ResourceHelper
      helper Decidim::ActionAuthorizationHelper

      helper_method :current_feature,
                    :current_manifest

      skip_authorize_resource

      before_action do
        authorize! :read, current_participatory_process
      end

      def current_feature
        request.env["decidim.current_feature"]
      end

      def current_manifest
        current_feature.manifest
      end

      def current_participatory_process
        request.env["decidim.current_participatory_process"]
      end

      def ability_context
        super.merge(
          current_manifest: current_manifest,
          current_participatory_process: current_participatory_process,
          current_settings: current_settings,
          feature_settings: feature_settings
        )
      end
    end
  end
end
