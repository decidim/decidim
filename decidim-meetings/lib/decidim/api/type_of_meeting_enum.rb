# frozen_string_literal: true

module Decidim
  module Meetings
    class TypeOfMeetingEnum < Decidim::Api::Types::BaseEnum
      description "The types of meetings"

      value "HYBRID", value: "hybrid", description: "Hybrid"
      value "IN_PERSON", value: "in_person", description: "In person"
      value "ONLINE", value: "online", description: "Online"
    end
  end
end
