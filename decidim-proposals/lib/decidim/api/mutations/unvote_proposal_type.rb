# frozen_string_literal: true

module Decidim
  module Proposals
    class UnvoteProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "UnvoteProposal"

      description "Removes a vote from a proposal"
      type Decidim::Proposals::ProposalType

      def resolve
        UnvoteProposal.call(object, current_user) do
          on(:ok) do
            return object.reload
          end
        end
      end

      def authorized?
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:unvote, :proposal, object, context)

        true
      end
    end
  end
end
