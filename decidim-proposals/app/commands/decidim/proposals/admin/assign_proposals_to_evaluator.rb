# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic to assign proposals to a given
      # evaluator.
      class AssignProposalsToEvaluator < Decidim::Command
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
              form.evaluator_roles.each do |evaluator_role|
                find_assignment(proposal, evaluator_role) || assign_proposal(proposal, evaluator_role)
                notify_evaluator(proposal, evaluator_role)
              end
            end
          end
        end

        def find_assignment(proposal, evaluator_role)
          Decidim::Proposals::EvaluationAssignment.find_by(
            proposal:,
            evaluator_role:
          )
        end

        def assign_proposal(proposal, evaluator_role)
          Decidim.traceability.create!(
            Decidim::Proposals::EvaluationAssignment,
            form.current_user,
            proposal:,
            evaluator_role:
          )
        end

        def notify_evaluator(proposal, evaluator_role)
          return unless evaluator_role.user.email_on_assigned_proposals?

          data = {
            event: "decidim.events.proposals.admin.proposal_assigned_to_evaluator",
            event_class: Decidim::Proposals::Admin::ProposalAssignedToEvaluatorEvent,
            resource: proposal,
            affected_users: [evaluator_role.user]
          }

          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
