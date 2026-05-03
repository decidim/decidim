# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HighlightedProcessesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        def highlighted_spaces
          @highlighted_spaces ||= promoted_groups + highlighted_processes
        end

        alias limited_highlighted_spaces highlighted_spaces

        def i18n_scope
          "decidim.participatory_processes.pages.home.highlighted_processes"
        end

        def all_path
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_processes_path(locale: I18n.locale)
        end

        def max_results
          model.settings.max_results
        end

        private

        def block_id
          "highlighted-processes"
        end

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
