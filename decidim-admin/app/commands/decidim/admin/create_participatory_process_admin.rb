# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process admin in the system.
    class CreateParticipatoryProcessAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - The ParticipatoryProcess that will hold the
      #   user role
      def initialize(form, participatory_process)
        @form = form
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
        return broadcast(:invalid) unless user

        create_role
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        form.errors.add(:email, :taken)
        broadcast(:invalid)
      end

      private

      attr_reader :form, :participatory_process

      def create_role
        role = :admin if form.roles.include?("process_admin")
        role = :collaborator if form.roles.include?("collaborator")

        ParticipatoryProcessUserRole.create!(
          role: role,
          user: user,
          participatory_process: @participatory_process
        )
      end

      def user
        @user ||= User.where(
          email: form.email,
          organization: participatory_process.organization
        ).first || InviteUser.call(user_form) do
          on(:ok) do |user|
            return user
          end
        end
      end

      def user_form
        OpenStruct.new({
          name: form.name,
          email: form.email.downcase,
          organization: current_organization,
          roles: form.roles,
          invited_by: current_user,
          invitation_instructions: "invite_admin"
        })
      end
    end
  end
end
