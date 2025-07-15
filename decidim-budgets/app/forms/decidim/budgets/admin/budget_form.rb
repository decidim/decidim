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
        translatable_attribute :description, Decidim::Attributes::RichText
        attribute :total_budget, Integer, default: 0
        attribute :decidim_scope_id, Integer

        validates :title, translatable_presence: true
        validates :weight, numericality: { greater_than_or_equal_to: 0 }
        validates :total_budget, numericality: { greater_than: 0 }
        validate :scope_available_in_budget_component, if: -> { decidim_scope_id.present? }

        def scope_available_in_budget_component
          return if (current_component.scopes&.ids || []).include?(decidim_scope_id)

          errors.add(:decidim_scope_id, :invalid)
        end
      end
    end
  end
end
