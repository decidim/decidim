# frozen_string_literal: true

module Decidim
  module Meetings
    class JoinMeetingForm < Decidim::Form
      attribute :user_group_id, Integer
      attribute :public_participation, Boolean, default: false
    end
  end
end
