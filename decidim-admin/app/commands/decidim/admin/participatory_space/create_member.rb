# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # A command with all the business logic when creating a new participatory space
      # member in the system.
      class CreateMember < Decidim::Command
        delegate :current_user, to: :form
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # member_to - The member_to that will hold the
        #   user role
        def initialize(form, member_to, via_csv: false)
          @form = form
          @member_to = member_to
          @via_csv = via_csv
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
            create_member
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :member_to, :user

        def create_member
          action = @via_csv ? "create_via_csv" : "create"
          Decidim.traceability.perform_action!(
            action,
            Decidim::ParticipatorySpace::Member,
            current_user,
            resource: {
              title: user.name
            }
          ) do
            Decidim::ParticipatorySpace::Member.find_or_create_by!(
              user:,
              participatory_space: @member_to,
              role: form.role,
              published: form.published
            )
          end
        end

        def existing_user
          return @existing_user if defined?(@existing_user)

          @existing_user = User.find_by(
            email: form.email.downcase,
            organization: member_to.organization
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
                         organization: member_to.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions:)
        end

        def invitation_instructions
          "invite_member"
        end
      end
    end
  end
end
