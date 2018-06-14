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

        def create_invitation!
          log_info = {
            resource: {
              title: meeting.title
            },
            participatory_space: {
              title: meeting.participatory_space.title
            }
          }

          @invite = Decidim.traceability.create!(
            Invite,
            invited_by,
            {
              user: user,
              meeting: meeting,
              sent_at: Time.current
            },
            log_info
          )
        end

        def invite_user
          if user.persisted?
            create_invitation!

            # The user has already been invited to sign up to another
            # meeting or resource and has not yet accepted the invitation
            if user.invited_to_sign_up?
              invite_user_to_sign_up
            else
              InviteJoinMeetingMailer.invite(user, meeting, invited_by).deliver_later
            end
          else
            user.name = form.name
            user.nickname = User.nicknamize(user.name)
            invite_user_to_sign_up
            create_invitation!
          end
        end

        def user
          @user ||= Decidim::User.find_or_initialize_by(
            organization: form.current_organization,
            email: form.email.downcase
          )
        end

        def invite_user_to_sign_up
          user.skip_reconfirmation!
          user.invite!(invited_by, invitation_instructions: "join_meeting", meeting: meeting)
        end
      end
    end
  end
end
