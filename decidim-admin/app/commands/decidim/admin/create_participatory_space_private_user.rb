# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory space
    # private user in the system.
    class CreateParticipatorySpacePrivateUser < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # private_user_to - The private_user_to that will hold the
      #   user role
      def initialize(form, current_user, private_user_to, via_csv: false)
        @form = form
        @current_user = current_user
        @private_user_to = private_user_to
        @via_csv = via_csv
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
          create_private_user
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        form.errors.add(:email, :taken)
        broadcast(:invalid)
      end

      private

      attr_reader :form, :private_user_to, :current_user, :user

      def create_private_user
        action = @via_csv ? "create_via_csv" : "create"
        Decidim.traceability.perform_action!(
          action,
          Decidim::ParticipatorySpacePrivateUser,
          current_user,
          resource: {
            title: user.name
          }
        ) do
          Decidim::ParticipatorySpacePrivateUser.find_or_create_by!(
            user:,
            privatable_to: @private_user_to
          )
        end
      end

      def existing_user
        return @existing_user if defined?(@existing_user)

        @existing_user = User.find_by(
          email: form.email,
          organization: private_user_to.organization
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
                       organization: private_user_to.organization,
                       admin: false,
                       invited_by: current_user,
                       invitation_instructions:)
      end

      def invitation_instructions
        "invite_private_user"
      end
    end
  end
end
