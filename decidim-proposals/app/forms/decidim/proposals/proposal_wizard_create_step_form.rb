# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalWizardCreateStepForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :body_template, String
      attribute :user_group_id, Integer

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      validate :proposal_length
      validate :body_is_not_bare_template

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

      def body_is_not_bare_template
        return if body_template.blank?

        errors.add(:body, :cant_be_equal_to_template) if body.presence == body_template.presence
      end
    end
  end
end
