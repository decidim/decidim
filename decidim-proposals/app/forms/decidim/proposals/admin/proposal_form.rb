# frozen_string_literal: true
module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    module Admin
      class ProposalForm < Decidim::Form
        mimic :proposal

        attribute :title, String
        attribute :body, String
        attribute :category_id, Integer
        attribute :scope_id, Integer
        attribute :feature, Decidim::Feature

        validates :title, :body, :feature, presence: true
        validates :category, presence: true, if: ->(form) { form.category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

        delegate :categories, to: :feature
        delegate :scopes, to: :current_organization

        # Finds the Category from the category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= feature.categories.where(id: category_id).first
        end

        # Finds the Scope from the scope_id.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= feature.scopes.where(id: scope_id).first
        end
      end
    end
  end
end
