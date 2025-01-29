# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module Directory
      module ApplicationHelper
        include PaginateHelper
        include Decidim::MapHelper
        include Decidim::Meetings::MapHelper
        include Decidim::Meetings::MeetingsHelper
        include Decidim::Comments::CommentsHelper
        include Decidim::SanitizeHelper
        include Decidim::CheckBoxesTreeHelper
        include Decidim::IconHelper
        include Decidim::FiltersHelper

        def filter_type_values
          type_values = flat_filter_values(*Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys, scope: "decidim.meetings.meetings.filters.type_values").map do |args|
            TreePoint.new(*args)
          end

          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.meetings.filters.type_values.all")),
            type_values
          )
        end

        def available_taxonomy_filters
          @available_taxonomy_filters ||= begin
            participatory_spaces = current_organization.public_participatory_spaces
            components = Decidim::Component.where(manifest_name: "meetings", participatory_space: participatory_spaces)
            filter_ids = components.map(&:settings).pluck(:taxonomy_filters).flatten.compact
            Decidim::TaxonomyFilter.for(current_organization).where(id: filter_ids)
          end
        end

        def filter_date_values
          %w(all upcoming past).map { |k| [k, t(k, scope: "decidim.meetings.meetings.filters.date_values")] }
        end

        def directory_meeting_spaces_values
          participatory_spaces = current_organization.public_participatory_spaces

          spaces = participatory_spaces.collect(&:model_name).uniq.map do |participatory_space|
            [participatory_space.name.underscore, participatory_space.human(count: 2)]
          end

          spaces.prepend(["", t("decidim.meetings.application_helper.filter_meeting_space_values.all")])

          filter_tree_from_array(spaces)
        end

        # Options to filter meetings by activity.
        def activity_filter_values
          %w(all my_meetings).map { |k| [k, t(k, scope: "decidim.meetings.meetings.filters")] }
        end
      end
    end
  end
end
