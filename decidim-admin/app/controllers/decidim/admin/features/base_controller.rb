# frozen_string_literal: true

module Decidim
  module Admin
    module Features
      # This controller is the abstract class from which all feature
      # controllers in their admin engines should inherit from.
      class BaseController < Admin::ApplicationController
        skip_authorize_resource
        include Settings
        
        include Decidim::Admin::ParticipatorySpaceAdminContext
        participatory_space_admin_layout

        helper Decidim::ResourceHelper
        helper Decidim::Admin::ExportsHelper

        helper_method :current_feature,
                      :current_participatory_space,
                      :parent_path

        before_action except: [:index, :show] do
          authorize! :manage, current_feature
        end

        before_action on: [:index, :show] do
          authorize! :read, current_feature
        end

        def current_feature
          request.env["decidim.current_feature"]
        end

        def current_participatory_space
          current_feature.participatory_space
        end

        def parent_path
          @parent_path ||= EngineRouter.admin_proxy(current_participatory_space).features_path
        end
      end
    end
  end
end
