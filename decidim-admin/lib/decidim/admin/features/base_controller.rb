# frozen_string_literal: true
module Decidim
  module Admin
    module Features
      # This controller is the abstract class from which all feature
      # controllers in their admin engines should inherit from.
      class BaseController < Admin::ApplicationController
        skip_authorize_resource
        include Concerns::ParticipatoryProcessAdmin
        include NeedsParticipatoryProcess
        helper_method :current_feature,
                      :current_participatory_process,
                      :parent_path,
                      :global_configuration,
                      :current_configuration

        before_action do
          authorize! :manage, current_feature
        end

        def current_feature
          request.env["decidim.current_feature"]
        end

        def current_participatory_process
          request.env["decidim.current_participatory_process"]
        end

        def parent_path
          decidim_admin.participatory_process_features_path(current_participatory_process)
        end

        def global_configuration
          current_feature.configuration
        end

        def current_configuration
          current_feature.step_configurations[active_step.id.to_s]
        end
      end
    end
  end
end
