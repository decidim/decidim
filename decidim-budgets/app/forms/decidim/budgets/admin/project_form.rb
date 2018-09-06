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

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }

        validate :scope_belongs_to_participatory_space_scope

        delegate :categories, to: :current_component

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)

          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals)
                                .try(:resource_scope, current_component)&.order(title: :asc)
                          &.map { |proposal| [Decidim::Proposals::ProposalPresenter.new(proposal).title, proposal.id] }
        end

        # Finds the Category from the decidim_category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.find_by(id: decidim_category_id)
        end

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? current_participatory_space.scopes.find_by(id: @decidim_scope_id) : current_participatory_space.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the project
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end

        private

        def scope_belongs_to_participatory_space_scope
          errors.add(:decidim_scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
        end
      end
    end
  end
end
