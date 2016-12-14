# frozen_string_literal: true
module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      mimic :proposal

      attribute :title, String
      attribute :body, String
      attribute :author, Decidim::User
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :feature, Decidim::Feature

      validates :title, :body, :author, :feature, presence: true
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

      # Finds the Category set with the category_id.
      #
      # Returns a Decidim::Category
      def category
        @category ||= feature.categories.where(id: category_id).first
      end

      # Finds the Scope set with the scope_id.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= feature.scopes.where(id: scope_id).first
      end
    end
  end
end
