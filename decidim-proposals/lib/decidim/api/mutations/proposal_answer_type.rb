# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalAnswerType < Decidim::Api::Types::BaseMutation
      graphql_name "Answer"

      description "Answers a proposal"
      type Decidim::Proposals::ProposalType
      required_scopes "api:read", "api:write", "admin:write"

      argument :attributes, AnswerProposalAttributes, description: "input attributes of a proposal", required: true

      def resolve(attributes:)
        answer_content = attributes.to_h.fetch(:answer_content, object.answer)
        internal_state = attributes.to_h.fetch(:state, object.internal_state)
        params = attributes.to_h.reverse_merge(
          internal_state:,
          answer: answer_content,
          cost: object.cost,
          cost_report: object.cost_report,
          execution_period: object.execution_period
        )

        form = form(Decidim::Proposals::Admin::ProposalAnswerForm).from_params(params)

        Admin::AnswerProposal.call(form, object) do
          on(:ok) do
            return object
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        authorized = super && allowed_to?(:create, :proposal_answer, object, context)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless authorized

        true
      end
    end
  end
end
