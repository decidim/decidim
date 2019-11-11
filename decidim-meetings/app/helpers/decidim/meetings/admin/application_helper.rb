# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def meeting_organizer_picker_text(form)
          return "" if form.object.organizer.blank?

          "#{form.object.organizer.name} (@#{form.object.organizer.nickname})"
        end

        def tabs_id_for_service(service)
          "meeting_service_#{service.to_param}"
        end

        def tabs_id_for_agenda_item(agenda_item)
          "meeting_agenda_item_#{agenda_item.to_param}"
        end

        def tabs_id_for_agenda_item_child(agenda_item)
          "meeting_agenda_item_#{agenda_item.to_param_child}"
        end
      end
    end
  end
end
