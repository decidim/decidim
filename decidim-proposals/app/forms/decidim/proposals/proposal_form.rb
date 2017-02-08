# frozen_string_literal: true
module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :user_group_id, Integer

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }
      validates :body, length: { maximum: 500 }, etiquette: true
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

      delegate :categories, to: :current_feature
      delegate :scopes, to: :current_organization

      alias feature current_feature

      # Finds the Category from the category_id.
      #
      # Returns a Decidim::Category
      def category
        @category ||= categories.where(id: category_id).first
      end

      # Finds the Scope from the scope_id.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= scopes.where(id: scope_id).first
      end
    end
  end
end
