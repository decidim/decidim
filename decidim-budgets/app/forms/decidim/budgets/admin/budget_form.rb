# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update budgets from Decidim's admin panel.
      class BudgetForm < Decidim::Form
        include TranslatableAttributes

        mimic :budget

        translatable_attribute :title, String
        attribute :weight, Integer, default: 0
        translatable_attribute :description, String
        attribute :total_budget, Integer, default: 0
        attribute :decidim_scope_id, Integer

        validates :title, translatable_presence: true
        validates :weight, :total_budget, numericality: { greater_than_or_equal_to: 0 }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :decidim_scope_id, scope_belongs_to_component: true, if: ->(form) { form.decidim_scope_id.present? }

        # Finds the Scope from the given decidim_scope_id, uses the compoenent scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? current_component.scopes.find_by(id: @decidim_scope_id) : current_component.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the meeting
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end
      end
    end
  end
end
