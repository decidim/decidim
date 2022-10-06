# frozen_string_literal: true

module Decidim
  module Admin
    # This is not a Command but an abstration of reusable methods by commands in participatory spaces that create space admins.
    # Expects the command to have a `participatory_space` attribute.
    module CreateParticipatorySpaceAdminUserActions
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
          existing_role || create_role
          add_admin_as_follower
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        form.errors.add(:email, :taken)
        broadcast(:invalid)
      end

      # This is command specific
      # It is expected to find if a UserRole for the same user, role and participatory_process already exist
      # Return a boolean, or some object equally evaluable
      def existing_role
        raise NotImplementedError
      end

      # This is command specific
      # It is expected to
      # - create a XxxUserRole using `Decidim.traceability`
      # - send a notification to the user telling she has been invited to manage the participatory space
      def create_role
        raise NotImplementedError
      end

      def existing_user
        return @existing_user if defined?(@existing_user)

        @existing_user = User.find_by(
          email: form.email,
          organization: @participatory_space.organization
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
                       organization: @participatory_space.organization,
                       admin: false,
                       invited_by: current_user,
                       invitation_instructions:)
      end

      def invitation_instructions
        return "invite_admin" if form.role == "admin"

        "invite_collaborator"
      end

      def add_admin_as_follower
        return if user.follows?(@participatory_space)

        form = Decidim::FollowForm
               .from_params(followable_gid: @participatory_space.to_signed_global_id.to_s)
               .with_context(
                 current_organization: @participatory_space.organization,
                 current_user: user
               )

        Decidim::CreateFollow.new(form, user).call
      end
    end
  end
end
