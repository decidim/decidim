# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalWizardCreateStepForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      validate :proposal_length

      alias component current_component

      private

      def proposal_length
        return unless body.presence
        length = current_component.settings.proposal_length
        errors.add(:body, :too_long, count: length) if body.length > length
      end
    end
  end
end
