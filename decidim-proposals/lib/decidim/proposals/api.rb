# frozen_string_literal: true

module Decidim
  module Proposals
    autoload :ProposalInputFilter, "decidim/api/proposal_input_filter"
    autoload :ProposalInputSort, "decidim/api/proposal_input_sort"
    autoload :ProposalType, "decidim/api/proposal_type"
    autoload :ProposalsType, "decidim/api/proposals_type"
    autoload :ProposalStateType, "decidim/api/proposal_state_type"
    autoload :ProposalsMutationType, "decidim/api/mutations/proposals_mutation_type"
    autoload :ProposalMutationType, "decidim/api/mutations/proposal_mutation_type"
    autoload :AnswerProposalType, "decidim/api/mutations/answer_proposal_type"
    autoload :AnswerProposalAttributes, "decidim/api/mutations/answer_proposal_attributes"
  end
end
