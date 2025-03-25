# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to answer a proposal.
      class ProposalAnswerForm < Decidim::Form
        include TranslatableAttributes

        mimic :proposal_answer

        translatable_attribute :answer, Decidim::Attributes::RichText
        translatable_attribute :cost_report, Decidim::Attributes::RichText
        translatable_attribute :execution_period, Decidim::Attributes::RichText
        attribute :cost, Float
        attribute :internal_state, String

        validates :internal_state, presence: true, inclusion: { in: :proposal_states }

        alias state internal_state

        def publish_answer?
          current_component.current_settings.publish_answers_immediately?
        end

        private

        def proposal_states
          Decidim::Proposals::ProposalState.where(component: current_component).pluck(:token).map(&:to_s) + ["not_answered"]
        end
      end
    end
  end
end
