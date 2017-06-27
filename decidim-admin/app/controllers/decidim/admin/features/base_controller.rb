# frozen_string_literal: true

module Decidim
  module Admin
    module Features
      # This controller is the abstract class from which all feature
      # controllers in their admin engines should inherit from.
      class BaseController < Admin::ApplicationController
        skip_authorize_resource
        include Concerns::ParticipatoryProcessAdmin
        include FeatureSettings

        helper Decidim::Admin::ExportsHelper

        helper_method :current_feature,
                      :current_participatory_process,
                      :parent_path

        delegate :active_step, to: :current_participatory_process, prefix: false

        before_action except: [:index, :show] do
          authorize! :manage, current_feature
        end

        before_action on: [:index, :show] do
          authorize! :read, current_feature
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
      end
    end
  end
end
