# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an conference.
      class ComponentShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::ConferenceAdmin

        def resource
          @resource ||= current_participatory_space.components.find(params[:component_id])
        end
      end
    end
  end
end
