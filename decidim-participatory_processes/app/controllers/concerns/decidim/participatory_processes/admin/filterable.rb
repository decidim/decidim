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
              :with_any_access_mode,
              :published_at_null,
              :decidim_participatory_process_group_id_eq
            ]
          end

          def filters_with_values
            {
              with_any_access_mode: access_modes,
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

          private

          def access_modes
            ParticipatoryProcess::ACCESS_MODES
          end
        end
      end
    end
  end
end
