# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to invite users to join a meeting.
      #
      class MeetingRegistrationInviteForm < Form
        attribute :name, String
        attribute :email, String
        attribute :user_id, Integer
        attribute :existing_user, Boolean, default: false

        validates :name, presence: true, unless: proc { |object| object.existing_user }
        validates :email, presence: true, "valid_email_2/email": { disposable: true }, unless: proc { |object| object.existing_user }
        validates :user, presence: true, if: proc { |object| object.existing_user }

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
