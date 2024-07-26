# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic to assign proposals to a given
      # valuator.
      class AssignProposalsToValuator < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          assign_proposals
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        private

        attr_reader :form

        def assign_proposals
          transaction do
            form.proposals.flat_map do |proposal|
              form.valuator_roles.each do |valuator_role|
                find_assignment(proposal, valuator_role) || assign_proposal(proposal, valuator_role)
                notify_valuator(proposal, valuator_role)
              end
            end
          end
        end

        def find_assignment(proposal, valuator_role)
          Decidim::Proposals::ValuationAssignment.find_by(
            proposal:,
            valuator_role:
          )
        end

        def assign_proposal(proposal, valuator_role)
          Decidim.traceability.create!(
            Decidim::Proposals::ValuationAssignment,
            form.current_user,
            proposal:,
            valuator_role:
          )
        end

        def notify_valuator(proposal, valuator_role)
          return unless valuator_role.user.email_on_assigned_proposals?

          data = {
            event: "decidim.events.proposals.admin.proposal_assigned_to_valuator",
            event_class: Decidim::Proposals::Admin::ProposalAssignedToValuatorEvent,
            resource: proposal,
            affected_users: [valuator_role.user]
          }

          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
