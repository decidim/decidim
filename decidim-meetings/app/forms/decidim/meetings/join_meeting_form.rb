# frozen_string_literal: true

module Decidim
  module Meetings
    class JoinMeetingForm < Decidim::Form
      attribute :public_participation, Boolean, default: false
    end
  end
end
