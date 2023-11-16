# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to answer a proposal.
      class ProposalAnswerForm < Decidim::Form
        include TranslatableAttributes
        mimic :proposal_answer

        translatable_attribute :answer, String
        translatable_attribute :cost_report, String
        translatable_attribute :execution_period, String
        attribute :cost, Float
        attribute :internal_state, String

        validates :internal_state, presence: true, inclusion: { in: :proposal_states }
        validates :answer, translatable_presence: true, if: ->(form) { form.state == "rejected" }

        with_options if: :costs_required? do
          validates :cost, numericality: true, presence: true
          validates :cost_report, translatable_presence: true
          validates :execution_period, translatable_presence: true
        end

        alias state internal_state

        def costs_required?
          costs_enabled? && state == "accepted"
        end

        def publish_answer?
          current_component.current_settings.publish_answers_immediately?
        end

        # TODO: This method should not be added to main repository
        def self.from_model(model)

          form_attributes = {
            id: model.id,
            internal_state: model.customized_proposal_internal_state,
            answer: model.answer,
            cost: model.cost,
            cost_report: model.cost_report,
            execution_period: model.execution_period
          }

          form = new(form_attributes)
          form.map_model(model)

          form
        end

        private

        def proposal_states
          Decidim::Proposals::ProposalState.where(component: current_component).pluck(:token).map(&:to_s)
        end

        def costs_enabled?
          current_component.current_settings.answers_with_costs?
        end
      end
    end
  end
end
