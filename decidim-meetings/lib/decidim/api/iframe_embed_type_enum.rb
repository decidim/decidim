# frozen_string_literal: true

module Decidim
  module Meetings
    class IframeEmbedTypeEnum < Decidim::Api::Types::BaseEnum
      description "The type of iframe embedded in the meeting"

      value "NONE", value: "none", description: "None", value_method: false
      value "EMBED_IN_MEETING_PAGE", value: "embed_in_meeting_page", description: "Embed in meeting page", value_method: false
      value "OPEN_IN_LIVE_EVENT_PAGE", value: "open_in_live_event_page", description: "Open in live event page", value_method: false
      value "OPEN_IN_NEW_TAB", value: "open_in_new_tab", description: "Open URL in a new tab", value_method: false
    end
  end
end
