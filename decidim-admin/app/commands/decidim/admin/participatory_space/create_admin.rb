# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      class CreateAdmin < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_space - The ParticipatoryProcess that will hold the
        #   user role
        def initialize(form, participatory_space, options = {})
          @form = form
          @current_user = form.current_user
          @participatory_space = participatory_space
          @event_class = options.delete(:event_class)
          @event = options.delete(:event)
          @role_class = options.delete(:role_class)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          ActiveRecord::Base.transaction do
            @user ||= existing_user || new_user
            existing_role || create_role
            add_admin_as_follower
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event_class = @event_class || (raise NotImplementedError, "You must define an event_class")

        def event = @event || (raise NotImplementedError, "You must define an event")

        def role_class = @role_class || (raise NotImplementedError, "You must define a role_class")

        # This is command specific
        # It is expected to
        # - create a XxxUserRole using `Decidim.traceability`
        # - send a notification to the user telling she has been invited to manage the participatory space
        def create_role
          Decidim.traceability.create!(role_class, current_user, role_params, extra_info)
          send_notification user
        end

        # This is command specific
        # It is expected to find if a UserRole for the same user, role and participatory_process already exist
        # Return a boolean, or some object equally evaluable
        def existing_role
          role_class.for_space(participatory_space).exists?(role: form.role.to_sym, user:)
        end

        def extra_info = { resource: { title: user.name } }

        def role_params = { role: form.role.to_sym, user:, role_class.new.target_space_association => participatory_space }

        def send_notification(user)
          Decidim::EventsManager.publish(
            event:,
            event_class:,
            resource: form.current_participatory_space,
            affected_users: [user],
            extra: {
              role: form.role
            }
          )
        end

        def new_user
          @new_user ||= InviteUser.call(user_form) do
            on(:ok) do |user|
              return user
            end
          end
        end

        def invitation_instructions
          return "invite_admin" if form.role == "admin"

          "invite_collaborator"
        end

        def user_form
          OpenStruct.new(name: form.name,
                         email: form.email.downcase,
                         organization: participatory_space.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions:)
        end

        def add_admin_as_follower
          return if user.follows?(participatory_space)

          form = Decidim::FollowForm
                 .from_params(followable_gid: participatory_space.to_signed_global_id.to_s)
                 .with_context(
                   current_organization: participatory_space.organization,
                   current_user: user
                 )

          Decidim::CreateFollow.new(form, user).call
        end

        def existing_user
          return @existing_user if defined?(@existing_user)

          @existing_user = User.find_by(email: form.email, organization: participatory_space.organization)

          InviteUserAgain.call(@existing_user, invitation_instructions) if @existing_user&.invitation_pending?

          @existing_user
        end
      end
    end
  end
end
