# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class HighlightedProcessGroupsCell < Decidim::ViewModel
        include Decidim::CardHelper

        def show
          return if elements.blank?

          render
        end

        def block_id
          "#{model.scope_name}-#{model.manifest_name}".parameterize.gsub("_", "-")
        end

        def elements
          @elements ||= case model.settings.order
                        when "recent"
                          base_relation.order(created_at: :desc)
                        else
                          base_relation.order_randomly(random_seed)
                        end.limit(max_results)
        end

        private

        def base_relation
          @base_relation ||= (
            Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcessGroups.new(current_organization) |
            Decidim::ParticipatoryProcesses::VisibleParticipatoryProcessGroups.new(current_user) |
            Decidim::ParticipatoryProcesses::PrioritizedParticipatoryProcessGroups.new
          ).query
        end

        def max_results
          model.settings.max_results
        end

        def random_seed
          rand * 2 - 1
        end
      end
    end
  end
end
