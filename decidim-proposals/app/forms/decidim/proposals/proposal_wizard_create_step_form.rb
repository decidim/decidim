# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalWizardCreateStepForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, Decidim::Attributes::CleanString
      attribute :body_template, String
      attribute :user_group_id, Integer

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { in: 15..150 }
      validates :body, proposal_length: {
        minimum: 15,
        maximum: ->(record) { record.component.settings.proposal_length }
      }

      validate :body_is_not_bare_template

      alias component current_component

      def map_model(model)
        self.title = translated_attribute(model.title)
        self.body = translated_attribute(model.body)

        self.user_group_id = model.user_groups.first&.id
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      private

      def body_is_not_bare_template
        return if body_template.blank?

        errors.add(:body, :cant_be_equal_to_template) if body.presence == body_template.presence
      end
    end
  end
end
