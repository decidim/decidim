# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HighlightedProcessesCell < Decidim::ViewModel
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::CardHelper
        include Cell::ViewModel::Partial
        include ParticipatoryProcessHelper
        include Decidim::ParticipatoryProcesses::Engine.routes.url_helpers

        delegate :current_user, to: :controller

        def show
          if single_item?
            render "single_process"
          elsif highlighted_items.any?
            render
          end
        end

        def single_item?
          highlighted_items.length == 1
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_items
          @highlighted_items ||= promoted_groups + highlighted_processes
        end

        def i18n_scope
          "decidim.participatory_processes.pages.home.highlighted_processes"
        end

        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end

        private

        def highlighted_processes
          @highlighted_processes ||= if highlighted_processes_max_results.zero?
                                       []
                                     else
                                       (
                                         OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user) |
                                         HighlightedParticipatoryProcesses.new |
                                         FilteredParticipatoryProcesses.new("active")
                                       ).query.with_attached_hero_image.includes([:organization, :hero_image_attachment]).limit(highlighted_processes_max_results)
                                     end
        end

        def promoted_groups
          @promoted_groups ||= (OrganizationParticipatoryProcessGroups.new(current_organization) | PromotedParticipatoryProcessGroups.new).query.limit(max_results)
        end

        def highlighted_processes_max_results
          @highlighted_processes_max_results ||= max_results - promoted_groups.count
        end
      end
    end
  end
end
