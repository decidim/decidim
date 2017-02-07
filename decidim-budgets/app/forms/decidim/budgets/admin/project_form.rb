# frozen_string_literal: true
module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update projects from Decidim's admin panel.
      class ProjectForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :short_description, String
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

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, context.current_feature)&.order(title: :asc)&.pluck(:title, :id)
        end

        def scope
          @scope ||= context.current_feature.scopes.where(id: decidim_scope_id).first
        end

        def category
          @category ||= context.current_feature.categories.where(id: decidim_category_id).first
        end
      end
    end
  end
end
