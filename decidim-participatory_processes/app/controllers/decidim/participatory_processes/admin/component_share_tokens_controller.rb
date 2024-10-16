# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an process.
      class ComponentShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::ParticipatoryProcessAdmin

        def resource
          @resource ||= current_participatory_space.components.find(params[:component_id])
        end
      end
    end
  end
end
