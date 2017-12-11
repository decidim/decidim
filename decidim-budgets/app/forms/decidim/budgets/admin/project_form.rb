# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update projects from Decidim's admin panel.
      class ProjectForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :budget, Integer
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer
        attribute :proposal_ids, Array[Integer]

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :budget, presence: true, numericality: { greater_than: 0 }

        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        delegate :categories, to: :current_feature

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)

          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        def participatory_space_scope
          current_feature.participatory_space.scope
        end

        alias feature current_feature

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, context.current_feature)&.order(title: :asc)&.pluck(:title, :id)
        end

        # Finds the Category from the decidim_category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.where(id: decidim_category_id).first
        end

        # Finds the Scope from the scope_id.
        #
        # Returns a Decidim::Scope
        def scope
          return unless current_feature && decidim_scope_id
          @scope ||= current_feature.scopes.where(id: decidim_scope_id).first
        end

        # Proposal scope_id, uses process scope if missing.
        #
        # Returns the scope identifier related to the proposal
        def decidim_scope_id
          @decidim_scope_id || participatory_space_scope&.id
        end
      end
    end
  end
end
