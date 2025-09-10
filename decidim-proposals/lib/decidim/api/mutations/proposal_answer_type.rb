# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalAnswerType < Decidim::Api::Types::BaseMutation
      graphql_name "Answer"

      description "Answers a proposal"
      type Decidim::Proposals::ProposalType

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

        form = Decidim::Proposals::Admin::ProposalAnswerForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_user:,
          current_organization: current_user.organization
        )

        Admin::AnswerProposal.call(form, object) do
          on(:ok) do
            return object
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.proposals.admin.proposals.answer.invalid")
          )
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :proposal_answer, object, context, scope: :admin)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
