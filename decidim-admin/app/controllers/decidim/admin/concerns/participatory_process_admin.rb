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
          include Decidim::NeedsParticipatoryProcess

          layout "decidim/admin/participatory_process"
        end
      end
    end
  end
end
