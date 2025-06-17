# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "ProposalMutation"
      description "a proposal which includes its available mutations"

      field :id, GraphQL::Types::ID, "Proposal's unique ID", null: false

      field :answer, Decidim::Proposals::ProposalType, null: true do
        description "Answer to a proposal"

        argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this proposal", required: false
        argument :cost, GraphQL::Types::Float, description: "Estimated cost of the proposal", required: false
        argument :cost_report, GraphQL::Types::JSON, description: "Report on expenses", required: false
        argument :execution_period, GraphQL::Types::JSON, description: "Report on the execution perioid", required: false
        argument :state, GraphQL::Types::String,
                 description: "The answer status in which the proposal is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
      end

      def answer(state:, answer_content: nil, cost: nil, cost_report: nil, execution_period: nil)
        params = {
          internal_state: state,
          answer: json_value(answer_content) || object.answer,
          component_id: object.component.id.to_s,
          proposal_id: object.id,
          cost: cost || object.cost,
          cost_report: json_value(cost_report) || object.cost_report,
          execution_period: json_value(execution_period) || object.execution_period
        }

        form = Decidim::Proposals::Admin::ProposalAnswerForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_organization: object.organization,
          current_user: context[:current_user]
        )

        Decidim::Proposals::Admin::AnswerProposal.call(form, object) do
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

      def self.authorized?(object, context)
        super && allowed_to?(:create, :proposal_answer, object, context, scope: :admin)
      end
    end
  end
end
