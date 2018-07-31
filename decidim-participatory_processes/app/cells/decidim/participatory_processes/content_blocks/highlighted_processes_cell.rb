# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HighlightedProcessesCell < Decidim::ViewModel
        delegate :current_organization, to: :controller
        delegate :current_user, to: :controller

        def show
          render if highlighted_processes.any?
        end

        def highlighted_processes
          OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user) |
            HighlightedParticipatoryProcesses.new |
            FilteredParticipatoryProcesses.new("active")
        end

        def i18n_scope
          "decidim.participatory_processes.pages.home.highlighted_processes"
        end

        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end
      end
    end
  end
end
