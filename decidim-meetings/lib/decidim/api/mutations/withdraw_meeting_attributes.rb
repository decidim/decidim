# frozen_string_literal: true

module Decidim
  module Meetings
    class WithdrawMeetingAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "WithdrawMeetingAttributes"
      description "Attributes for withdrawing a meeting"

      # The WithdrawMeeting command doesn't require any additional attributes
      # as it only needs the meeting and current_user which are provided via context
    end
  end
end
