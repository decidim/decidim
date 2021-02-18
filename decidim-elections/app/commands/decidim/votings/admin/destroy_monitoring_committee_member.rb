# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to destroy a monitoring committee member
      class DestroyMonitoringCommitteeMember < Rectify::Command
        # Public: Initializes the command.
        #
        # monitoring_committee_member - the MonitoringCommitteeMember to destroy
        # current_user - the user performing this action
        def initialize(monitoring_committee_member, current_user)
          @monitoring_committee_member = monitoring_committee_member
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_monitoring_committee_member!
          broadcast(:ok)
        end

        private

        attr_reader :monitoring_committee_member, :current_user

        def destroy_monitoring_committee_member!
          extra_info = {
            resource: {
              title: monitoring_committee_member.user.name
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            monitoring_committee_member,
            current_user,
            extra_info
          ) do
            monitoring_committee_member.destroy!
          end
        end
      end
    end
  end
end
