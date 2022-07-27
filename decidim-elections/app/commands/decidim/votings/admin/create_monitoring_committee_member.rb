# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to create a new monitoring committee member
      class CreateMonitoringCommitteeMember < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params
        # current_user - The user creating the monitoring committee member
        # voting - The Voting that will hold the monitoring committee member
        def initialize(form, current_user, voting)
          @form = form
          @current_user = current_user
          @voting = voting
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
            user = retrieve_or_invite_user
            create_monitoring_committee_member(user)
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:email, :taken)
          broadcast(:invalid)
        end

        private

        attr_reader :form, :voting, :current_user

        def retrieve_or_invite_user
          form.user || existing_user || new_user
        end

        def create_monitoring_committee_member(user)
          Decidim.traceability.perform_action!(
            :create,
            Decidim::Votings::MonitoringCommitteeMember,
            current_user,
            resource: {
              title: user.name
            }
          ) do
            Decidim::Votings::MonitoringCommitteeMember.find_or_create_by!(
              user:,
              voting:
            )
          end
        end

        def existing_user
          @existing_user ||= begin
            tentative_user = User.find_by(
              email: form.email,
              organization: voting.organization
            )

            InviteUserAgain.call(tentative_user, invitation_instructions) if tentative_user&.invitation_pending?

            tentative_user
          end
        end

        def new_user
          @new_user ||= InviteUser.call(invite_user_form) do
            on(:ok) do |invited_user|
              return invited_user
            end
          end
        end

        def invite_user_form
          OpenStruct.new(name: form.name,
                         email: form.email.downcase,
                         organization: voting.organization,
                         admin: false,
                         invited_by: current_user,
                         invitation_instructions:)
        end

        def invitation_instructions
          "invite_collaborator"
        end
      end
    end
  end
end
