# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalWizardCreateStepForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :user_group_id, Integer

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      validate :proposal_length

      alias component current_component

      def map_model(model)
        self.user_group_id = model.user_groups.first&.id
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      private

      def proposal_length
        return unless body.presence
        length = current_component.settings.proposal_length
        errors.add(:body, :too_long, count: length) if body.length > length
      end
    end
  end
end
