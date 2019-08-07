# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateParticipatoryProcessAdmin < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # current_user - the user performing this action
        # participatory_process - The ParticipatoryProcess that will hold the
        #   user role
        def initialize(form, current_user, participatory_process)
          @form = form
          @current_user = current_user
          @participatory_process = participatory_process
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
            @user = existing_user || new_user
            existing_role || create_role
            add_admin_as_follower
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :participatory_process, :current_user, :user

        def create_role
          extra_info = {
            resource: {
              title: user.name
            }
          }
          role_params = {
            role: form.role.to_sym,
            user: user,
            participatory_process: @participatory_process
          }

          Decidim.traceability.create!(
            Decidim::ParticipatoryProcessUserRole,
            current_user,
            role_params,
            extra_info
          )
        end

        def existing_role
          Decidim::ParticipatoryProcessUserRole.find_by(
            role: form.role.to_sym,
            user: user,
            participatory_process: @participatory_process
          )
        end

        def existing_user
          return @existing_user if defined?(@existing_user)

          @existing_user = User.find_by(
            email: form.email,
            organization: participatory_process.organization
          )

          InviteUserAgain.call(@existing_user, invitation_instructions) if @existing_user && !@existing_user.invitation_accepted?

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
                         organization: participatory_process.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions: invitation_instructions)
        end

        def invitation_instructions
          return "invite_admin" if form.role == "admin"

          "invite_collaborator"
        end

        def add_admin_as_follower
          return if user.follows?(participatory_process)

          form = Decidim::FollowForm
                 .from_params(followable_gid: participatory_process.to_signed_global_id.to_s)
                 .with_context(
                   current_organization: participatory_process.organization,
                   current_user: user
                 )

          Decidim::CreateFollow.new(form, user).call
        end
      end
    end
  end
end
