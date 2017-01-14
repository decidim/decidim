# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Decidim::Form
        mimic :proposal

        attribute :title, String
        attribute :body, String
        attribute :category_id, Integer
        attribute :scope_id, Integer

        validates :title, :body, presence: true
        validates :category, presence: true, if: ->(form) { form.category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

        delegate :categories, to: :current_feature, prefix: false
        delegate :scopes, to: :current_organization, prefix: false

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
end
