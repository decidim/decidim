# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin answers a proposal.
      class AnswerProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # proposal - The proposal to write the answer for.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          store_initial_proposal_status

          answer_proposal

          NotifyProposalAnswer.call(proposal, initial_state) if initial_answered_at.present? || form.publish_answer?

          broadcast(:ok)
        end

        private

        attr_reader :form, :proposal, :initial_answered_at, :initial_state

        def answer_proposal
          Decidim.traceability.perform_action!(
            "answer",
            proposal,
            form.current_user
          ) do
            attributes = {
              state: form.state,
              answer: form.answer,
              cost: form.cost,
              cost_report: form.cost_report,
              execution_period: form.execution_period
            }

            attributes[:answered_at] = Time.current if form.publish_answer?

            proposal.update!(attributes)
          end
        end

        def store_initial_proposal_status
          @initial_answered_at = proposal.answered_at
          @initial_state = proposal.state
        end
      end
    end
  end
end
