# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatoryProcesses
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def filters
            [
              :private_space_eq,
              :published_at_null,
              :decidim_participatory_process_group_id_eq
            ]
          end

          def filters_with_values
            {
              private_space_eq: [true, false],
              published_at_null: [true, false],
              decidim_participatory_process_group_id_eq: OrganizationParticipatoryProcessGroups.new(current_organization).pluck(:id)
            }
          end

          def dynamically_translated_filters
            [:decidim_participatory_process_group_id_eq]
          end

          def translated_decidim_participatory_process_group_id_eq(id)
            translated_attribute(Decidim::ParticipatoryProcessGroup.find(id).title)
          end
        end
      end
    end
  end
end
