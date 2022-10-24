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
        # - :invalid if the form wasn't valid and we couldn't proceed.
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
              find_assignment(proposal) || assign_proposal(proposal)
            end
          end
        end

        def find_assignment(proposal)
          Decidim::Proposals::ValuationAssignment.find_by(
            proposal:,
            valuator_role: form.valuator_role
          )
        end

        def assign_proposal(proposal)
          Decidim.traceability.create!(
            Decidim::Proposals::ValuationAssignment,
            form.current_user,
            proposal:,
            valuator_role: form.valuator_role
          )
        end
      end
    end
  end
end
