# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to answer a proposal.
      class ProposalAnswerForm < Decidim::Form
        include TranslatableAttributes
        mimic :proposal_answer

        translatable_attribute :answer, String
        attribute :state, String

        validates :state, presence: true, inclusion: { in: %w(accepted rejected evaluating) }
        validates :answer, translatable_presence: true, if: ->(form) { form.state == "rejected" }
      end
    end
  end
end
