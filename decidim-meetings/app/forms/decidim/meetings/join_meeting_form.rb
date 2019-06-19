# frozen_string_literal: true

module Decidim
  module Meetings
    class JoinMeetingForm < Decidim::Form
      attribute :user_group_id, Integer
    end
  end
end
