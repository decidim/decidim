# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # This concern is meant to be included in all controllers that are scoped
      # into a participatory process' admin panel. It will override the layout
      # so it shows the sidebar, preload the participatory process, etc.
      module ParticipatoryProcessAdmin
        extend ActiveSupport::Concern

        included do
          helper_method :participatory_process

          layout "decidim/admin/participatory_process"
        end

        private

        def participatory_process
          @participatory_process ||=
            current_organization.participatory_processes.find(params[:participatory_process_id])
        end
      end
    end
  end
end
