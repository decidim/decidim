# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic to invite users to join a conference.
      #
      class InviteUserToJoinConference < Decidim::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # conference      - The conference which the user is invited to.
        # invited_by   - The user performing the operation
        def initialize(form, conference, invited_by)
          @form = form
          @conference = conference
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

        attr_reader :form, :invited_by, :conference

        def already_invited?
          return false unless user.persisted?
          return false unless conference.conference_invites.exists?(user:)

          form.errors.add(:email, :already_invited)
          true
        end

        def create_invitation!
          log_info = {
            resource: {
              title: conference.title
            },
            participatory_space: {
              title: conference.title
            }
          }

          @conference_invite = Decidim.traceability.create!(
            Decidim::Conferences::ConferenceInvite,
            invited_by,
            {
              user:,
              conference:,
              registration_type: form.registration_type,
              sent_at: Time.current
            },
            log_info
          )
        end

        def invite_user
          if user.persisted?
            create_invitation!

            # The user has already been invited to sign up to another
            # conference or resource and has not yet accepted the invitation
            if user.invited_to_sign_up?
              invite_user_to_sign_up
            else
              InviteJoinConferenceMailer.invite(user, conference, form.registration_type, invited_by).deliver_later
            end
          else
            user.name = form.name
            user.nickname = UserBaseEntity.nicknamize(user.name, user.decidim_organization_id)
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
          user.invite!(invited_by, invitation_instructions: "join_conference", conference:, registration_type: form.registration_type)
        end
      end
    end
  end
end
