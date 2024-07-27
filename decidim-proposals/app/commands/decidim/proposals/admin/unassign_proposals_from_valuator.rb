# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic to unassign proposals from a given
      # valuator.
      class UnassignProposalsFromValuator < Decidim::Command
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

          unassign_proposals
          broadcast(:ok)
        end

        private

        attr_reader :form

        def unassign_proposals
          transaction do
            form.proposals.flat_map do |proposal|
              form.valuator_roles.each do |valuator_role|
                assignment = find_assignment(proposal, valuator_role)
                unassign(assignment) if assignment
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

        def unassign(assignment)
          Decidim.traceability.perform_action!(
            :delete,
            assignment,
            form.current_user,
            proposal_title: assignment.proposal.title
          ) do
            assignment.destroy!
          end
        end
      end
    end
  end
end
