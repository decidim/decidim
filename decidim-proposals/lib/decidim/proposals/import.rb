# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      autoload :ProposalAnswerCreator, "decidim/proposals/import/proposal_answer_creator"
      autoload :ProposalCreator, "decidim/proposals/import/proposal_creator"
      autoload :ProposalsAnswersVerifier, "decidim/proposals/import/proposals_answers_verifier"
      autoload :ProposalsVerifier, "decidim/proposals/import/proposals_verifier"
    end
  end
end
