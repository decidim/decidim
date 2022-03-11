# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class HighlightedParticipatoryProcessesCell < Decidim::ViewModel
        include Decidim::CardHelper
        include Decidim::IconHelper
        include ActionView::Helpers::FormOptionsHelper
        include Decidim::FiltersHelper
        include Decidim::FilterResource

        def participatory_process_group
          @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(model.scoped_resource_id)
        end

        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end

        def block_id
          "processes-grid"
        end

        def filtered_relation
          @filtered_relation ||= search.result
        end

        def default_date_filter
          return "active" if filtered_relation.any?(&:active?)
          return "upcoming" if filtered_relation.any?(&:upcoming?)
          return "past" if filtered_relation.any?(&:past?)

          "all"
        end

        private

        def search_collection
          base_relation
        end

        def default_filter_params
          {
            with_scope: nil,
            with_area: nil,
            with_type: nil
          }
        end

        def base_relation
          @base_relation ||= Decidim::ParticipatoryProcesses::GroupPublishedParticipatoryProcesses.new(
            participatory_process_group,
            current_user
          ).query
        end
      end
    end
  end
end
