# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to invite users to join a meeting.
      #
      class MeetingRegistrationInviteForm < Form
        attribute :email, String

        validates :email, presence: true
      end
    end
  end
end
