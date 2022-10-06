# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # admin in the system.
      class CreateConferenceAdmin < NotifyRoleAssignedToConference
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference - The Conference that will hold the
        #   user role
        def initialize(form, current_user, conference)
          @form = form
          @current_user = current_user
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          ActiveRecord::Base.transaction do
            @user ||= existing_user || new_user
            create_role
            add_admin_as_follower
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :conference, :current_user, :user

        def create_role
          Decidim.traceability.perform_action!(
            :create,
            Decidim::ConferenceUserRole,
            current_user,
            resource: {
              title: user.name
            }
          ) do
            Decidim::ConferenceUserRole.find_or_create_by!(
              role: form.role.to_sym,
              user:,
              conference: @conference
            )
          end
          send_notification user
        end

        def existing_user
          return @existing_user if defined?(@existing_user)

          @existing_user = User.find_by(
            email: form.email,
            organization: conference.organization
          )

          InviteUserAgain.call(@existing_user, invitation_instructions) if @existing_user&.invitation_pending?

          @existing_user
        end

        def new_user
          @new_user ||= InviteUser.call(user_form) do
            on(:ok) do |user|
              return user
            end
          end
        end

        def user_form
          OpenStruct.new(name: form.name,
                         email: form.email.downcase,
                         organization: conference.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions:)
        end

        def invitation_instructions
          return "invite_admin" if form.role == "admin"

          "invite_collaborator"
        end

        def add_admin_as_follower
          return if user.follows?(conference)

          form = Decidim::FollowForm
                 .from_params(followable_gid: conference.to_signed_global_id.to_s)
                 .with_context(
                   current_organization: conference.organization,
                   current_user: user
                 )

          Decidim::CreateFollow.new(form, user).call
        end
      end
    end
  end
end
