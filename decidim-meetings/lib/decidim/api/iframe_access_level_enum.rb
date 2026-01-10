# frozen_string_literal: true

module Decidim
  module Meetings
    class IframeAccessLevelEnum < Decidim::Api::Types::BaseEnum
      description "The iframe access level of the meeting"

      value "ALL", value: "all", description: "All visitors", value_method: false
      value "SIGNED_IN", value: "signed_in", description: "Only signed-in participants", value_method: false
      value "REGISTERED", value: "registered", description: "Registered participants to this meeting", value_method: false
    end
  end
end
