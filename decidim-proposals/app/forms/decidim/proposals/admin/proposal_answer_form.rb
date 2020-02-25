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
        attribute :state, String

        validates :state, presence: true, inclusion: { in: %w(accepted rejected evaluating) }
        validates :answer, translatable_presence: true, if: ->(form) { form.state == "rejected" }

        with_options if: :costs_required? do
          validates :cost, numericality: true, presence: true
          validates :cost_report, translatable_presence: true
          validates :execution_period, translatable_presence: true
        end

        def costs_required?
          costs_enabled? && state == "accepted"
        end

        private

        def costs_enabled?
          current_component.current_settings.answers_with_costs?
        end
      end
    end
  end
end
