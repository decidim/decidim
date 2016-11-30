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
        helper_method :current_feature

        before_filter do
          authorize! :manage, current_participatory_process
        end

        private

        def current_feature
          @current_feature ||= current_organization.features.find(params[:feature_id])
        end
      end
    end
  end
end
