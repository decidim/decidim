# frozen_string_literal: true

module Decidim
  module Meetings
    autoload :AgendaItemType, "decidim/api/agenda_item_type"
    autoload :AgendaType, "decidim/api/agenda_type"
    autoload :MeetingType, "decidim/api/meeting_type"
    autoload :MeetingsType, "decidim/api/meetings_type"
    autoload :ServiceType, "decidim/api/service_type"

    autoload :LinkedResourcesInterface, "decidim/api/linked_resources_interface"
    autoload :ServicesInterface, "decidim/api/services_interface"

    autoload :MeetingAttributes, "decidim/api/mutations/meeting_attributes"
    autoload :CloseMeetingAttributes, "decidim/api/mutations/close_meeting_attributes"

    autoload :CreateMeetingType, "decidim/api/mutations/create_meeting_type"
    autoload :CloseMeetingType, "decidim/api/mutations/close_meeting_type"
    autoload :MeetingsMutationType, "decidim/api/mutations/meetings_mutation_type"
    autoload :MeetingMutationType, "decidim/api/mutations/meeting_mutation_type"
    autoload :UpdateMeetingType, "decidim/api/mutations/update_meeting_type"
    autoload :WithdrawMeetingType, "decidim/api/mutations/withdraw_meeting_type"

    autoload :IframeAccessLevelEnum, "decidim/api/iframe_access_level_enum"
    autoload :IframeEmbedTypeEnum, "decidim/api/iframe_embed_type_enum"
    autoload :RegistrationTypeEnum, "decidim/api/registration_type_enum"
    autoload :TypeOfMeetingEnum, "decidim/api/type_of_meeting_enum"
  end
end
