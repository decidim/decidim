# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Meetings
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          helper Decidim::Meetings::Admin::FilterableHelper

          private

          def base_query
            Meeting
              .not_hidden
              .where(component: current_component)
              .or(MeetingLink.find_meetings(component: current_component))
              .order(start_time: :desc)
              .page(params[:page])
              .per(15)
          end

          def filters
            [
              :with_any_type,
              :is_upcoming_true,
              :taxonomies_part_of_contains,
              :with_any_origin,
              :closed_at_present
            ]
          end

          def filters_with_values
            {
              with_any_type: meeting_types,
              taxonomies_part_of_contains: taxonomy_ids_hash(available_root_taxonomies),
              closed_at_present: %w(true false),
              is_upcoming_true: %w(true false),
              with_any_origin: %w(participants official)
            }
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def meeting_types
            Meeting::TYPE_OF_MEETING
          end
        end
      end
    end
  end
end
