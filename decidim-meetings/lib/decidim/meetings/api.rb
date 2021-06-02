# frozen_string_literal: true

module Decidim
  module Meetings
    autoload :AgendaItemType, "decidim/api/agenda_item_type"
    autoload :AgendaType, "decidim/api/agenda_type"
    autoload :MeetingType, "decidim/api/meeting_type"
    autoload :MeetingsType, "decidim/api/meetings_type"
    autoload :MinutesType, "decidim/api/minutes_type"
    autoload :ServiceType, "decidim/api/service_type"
    autoload :LinkedResourcesInterface, "decidim/api/linked_resources_interface"
    autoload :ServicesInterface, "decidim/api/services_interface"
  end
end
