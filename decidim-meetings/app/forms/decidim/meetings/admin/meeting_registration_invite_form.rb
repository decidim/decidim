# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to invite users to join a meeting.
      #
      class MeetingRegistrationInviteForm < Form
        attribute :name, String
        attribute :email, String

        validates :name, presence: true
        validates :email, presence: true, 'valid_email_2/email': { disposable: true }
      end
    end
  end
end
