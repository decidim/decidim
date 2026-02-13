# frozen_string_literal: true

module Decidim
  module Proposals
    class VoteProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "VoteProposal"

      description "Votes a proposal"
      type Decidim::Proposals::ProposalType

      def resolve
        VoteProposal.call(object, current_user) do
          on(:ok) do
            return object.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::ValidationError, I18n.t("proposal_votes.create.error", scope: "decidim.proposals")
          end
        end
      end

      def authorized?
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:vote, :proposal, object, context)

        true
      end
    end
  end
end
