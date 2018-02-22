# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :user_group_id, Integer
      attribute :has_address, Boolean
      attribute :attachment, AttachmentForm
      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }
      validates :address, geocoding: true, if: ->(form) { Decidim.geocoder.present? && form.has_address? }
      validates :address, presence: true, if: ->(form) { form.has_address? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
      validate { errors.add(:scope_id, :invalid) if current_participatory_space&.scope && !current_participatory_space&.scope&.ancestor_of?(scope) }
      validate :proposal_length

      delegate :categories, to: :current_feature

      def map_model(model)
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      alias feature current_feature
      # Finds the Category from the category_id.
      #
      # Returns a Decidim::Category
      def category
        @category ||= categories.find_by(id: category_id)
      end

      # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @scope_id ? current_feature.scopes.find_by(id: @scope_id) : current_participatory_space&.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the proposal
      def scope_id
        @scope_id || scope&.id
      end

      def has_address?
        current_feature.settings.geocoding_enabled? && has_address
      end

      def proposal_length
        return unless body.presence
        length = current_feature.settings.proposal_length
        errors.add(:body, :too_long, count: length) if body.length > length
      end
    end
  end
end
