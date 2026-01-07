# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "MeetingMutation"
      description "A meeting which includes its available mutations"

      field :withdraw, mutation: Decidim::Meetings::WithdrawMeetingType, description: "Withdraws a meeting"
    end
  end
end
