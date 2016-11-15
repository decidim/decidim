# frozen_string_literal: true
module Decidim
  module Admin
    module Components
      class BaseController < Admin::ApplicationController
        skip_authorize_resource
        include Concerns::ParticipatoryProcessAdmin
        include NeedsParticipatoryProcess
        helper_method :current_component

        before_filter do
          authorize! :manage, current_participatory_process
        end

        private

        def current_component
          env["decidim.current_component"]
        end
      end
    end
  end
end
