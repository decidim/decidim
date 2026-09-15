# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to invite users to join a meeting.
      #
      class MeetingRegistrationInviteForm < Form
        attribute :email, String
        attribute :user_id, Integer
        attribute :attendee_type, String, default: "name"

        validates :attendee_type, presence: true, inclusion: { in: %w(name email) }
        validates :user, presence: true, if: proc { |object| object.attendee_type == "name" }
        validates :email, presence: true, "valid_email_2/email": { disposable: true }, if: proc { |object| object.attendee_type == "email" }

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
