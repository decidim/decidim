# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalAnswerJob < ApplicationJob
        queue_as :default

        def perform(proposal_id, answer_form_params, current_component)
          proposal = Decidim::Proposals::Proposal.find(proposal_id)
          answer_form = ProposalAnswerForm.from_params(answer_form_params).with_context(current_component:)

          Admin::AnswerProposal.call(answer_form, proposal) do
            on(:ok) { Rails.logger.info "Proposal #{proposal.id} answered successfully." }
            on(:invalid) { Rails.logger.error "Proposal ID #{proposal.id} could not be updated. Errors: #{answer_form.errors.full_messages}" }
          end
        end
      end
    end
  end
end
