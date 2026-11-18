# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic to invite users to join a meeting.
      #
      class InviteUserToJoinMeeting < Decidim::Command
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
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || already_invited?

          invite_user

          broadcast(:ok)
        end

        private

        attr_reader :form, :invited_by, :meeting

        def already_invited?
          return false unless user.persisted?
          return false unless meeting.invites.exists?(user:)

          form.errors.add(:email, :already_invited)
          true
        end

        def create_invitation!
          log_info = {
            resource: {
              title: meeting.title
            },
            participatory_space: {
              title: meeting.participatory_space.title
            },
            attendee_name: user.name
          }

          @invite = Decidim.traceability.create!(
            Invite,
            invited_by,
            {
              user:,
              meeting:,
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
            user.nickname = User.nicknamize(user.name, user.decidim_organization_id)
            invite_user_to_sign_up
            create_invitation!
          end
        end

        def user
          @user ||= if form.existing_user
                      form.user
                    else
                      Decidim::User.find_or_initialize_by(
                        organization: form.current_organization,
                        email: form.email.downcase
                      )
                    end
        end

        def invite_user_to_sign_up
          user.skip_reconfirmation!
          user.invite!(invited_by, invitation_instructions: "join_meeting", meeting:)
        end
      end
    end
  end
end
