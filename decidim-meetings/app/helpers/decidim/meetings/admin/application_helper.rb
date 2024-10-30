# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper
        include Decidim::PaginateHelper

        def tabs_id_for_service(service)
          "meeting_service_#{service.to_param}"
        end

        def tabs_id_for_agenda_item(agenda_item)
          "meeting_agenda_item_#{agenda_item.to_param}"
        end

        def tabs_id_for_agenda_item_child(agenda_item)
          "meeting_agenda_item_#{agenda_item.to_param_child}"
        end

        def find_meeting_components_for_select
          spaces = current_organization.public_participatory_spaces
          meeting_components = Decidim::Component
                               .where(manifest_name: "meetings", participatory_space_id: spaces.pluck(:id))
                               .where.not(id: current_component.id)

          meeting_components.map do |component|
            [component.hierarchy_title, component.id]
          end.sort_by(&:first)
        end
      end
    end
  end
end
