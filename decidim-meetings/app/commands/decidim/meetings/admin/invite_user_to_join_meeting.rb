# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic to invite users to join a meeting.
      #
      class InviteUserToJoinMeeting < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # meeting      - The meeting which the user is invited to.
        # invited_by   - The user performing the operation
        def initialize(form, meeting, invited_by)
          @form = form
          @meeting = meeting
          @invited_by = invited_by
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          invite_user

          broadcast(:ok)
        end

        private

        attr_reader :form, :invited_by, :meeting

        def invite_user
          if user.persisted?
            InviteJoinMeetingMailer.invite(user, meeting).deliver_later
          else
            user.name = form.name
            user.skip_reconfirmation!
            user.invite!(invited_by, invitation_instructions: "join_meeting", meeting: meeting)
          end
        end

        def user
          @user ||= Decidim::User.find_or_create_by(
            organization: form.current_organization,
            email: form.email.downcase
          )
        end
      end
    end
  end
end
