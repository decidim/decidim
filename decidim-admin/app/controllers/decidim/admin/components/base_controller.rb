# frozen_string_literal: true

module Decidim
  module Admin
    module Components
      # This controller is the abstract class from which all component
      # controllers in their admin engines should inherit from.
      class BaseController < Admin::ApplicationController
        skip_authorize_resource
        include Settings

        include Decidim::Admin::ParticipatorySpaceAdminContext
        participatory_space_admin_layout

        helper Decidim::ResourceHelper
        helper Decidim::Admin::ExportsHelper
        helper Decidim::Admin::BulkActionsHelper

        helper_method :current_component,
                      :current_participatory_space,
                      :parent_path

        before_action except: [:index, :show] do
          authorize! :manage, current_component
        end

        before_action on: [:index, :show] do
          authorize! :read, current_component
        end

        def current_component
          request.env["decidim.current_component"]
        end

        def current_participatory_space
          current_component.participatory_space
        end

        def parent_path
          @parent_path ||= EngineRouter.admin_proxy(current_participatory_space).components_path
        end
      end
    end
  end
end
