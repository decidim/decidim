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

          store_initial_proposal_state

          transaction do
            answer_proposal
            notify_proposal_answer
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :proposal, :initial_has_state_published, :initial_state

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

            if form.state == "not_answered"
              attributes[:answered_at] = nil
              attributes[:state_published_at] = nil
            else
              attributes[:answered_at] = Time.current
              attributes[:state_published_at] = Time.current if !initial_has_state_published && form.publish_answer?
            end

            proposal.update!(attributes)
          end
        end

        def notify_proposal_answer
          return if !initial_has_state_published && !form.publish_answer?

          NotifyProposalAnswer.call(proposal, initial_state)
        end

        def store_initial_proposal_state
          @initial_has_state_published = proposal.published_state?
          @initial_state = proposal.state
        end
      end
    end
  end
end
