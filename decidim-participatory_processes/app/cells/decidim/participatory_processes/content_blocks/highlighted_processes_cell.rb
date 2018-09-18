# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HighlightedProcessesCell < Decidim::ViewModel
        include Decidim::SanitizeHelper

        delegate :current_organization, to: :controller
        delegate :current_user, to: :controller

        def show
          if single_process?
            render "single_process"
          elsif highlighted_processes.any?
            render
          end
        end

        def single_process?
          highlighted_processes.to_a.length == 1
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_processes
          @highlighted_processes ||= (
            OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user) |
            HighlightedParticipatoryProcesses.new |
            FilteredParticipatoryProcesses.new("active")
          ).query.limit(max_results)
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
