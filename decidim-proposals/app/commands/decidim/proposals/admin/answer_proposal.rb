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

          answer_proposal
          broadcast(:ok)
        end

        private

        attr_reader :form, :proposal

        def answer_proposal
          proposal.update_attributes!(
            state: @form.state,
            answer: @form.answer,
            answered_at: Time.current
          )
        end
      end
    end
  end
end
