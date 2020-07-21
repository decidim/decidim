# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update results from Decidim's admin panel.
      class ResultForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer
        attribute :proposal_ids, Array[Integer]
        attribute :project_ids, Array[Integer]
        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :progress, Float
        attribute :decidim_accountability_status_id, Integer
        attribute :parent_id, Integer
        attribute :external_id, String
        attribute :weight, Float

        validates :title, translatable_presence: true

        validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: ->(form) { form.progress.present? }

        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :decidim_scope_id, scope_belongs_to_component: true, if: ->(form) { form.decidim_scope_id.present? }

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        validates :parent, presence: true, if: ->(form) { form.parent_id.present? }
        validates :status, presence: true, if: ->(form) { form.decidim_accountability_status_id.present? }

        delegate :categories, to: :current_component

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)
          self.project_ids = model.linked_resources(:projects, "included_projects").pluck(:id)
          self.decidim_category_id = model.category.try(:id)
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals)
                                .try(:resource_scope, current_component)
                                &.where(id: proposal_ids)
                                &.order(title: :asc)
        end

        def projects
          @projects ||= Decidim.find_resource_manifest(:projects).try(:resource_scope, current_component)&.order(title: :asc)
                               &.select(:title, :id)&.map { |a| [a.title[I18n.locale.to_s], a.id] }
        end

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? component.scopes.find_by(id: @decidim_scope_id) : component.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the result
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end

        def category
          @category ||= categories.find_by(id: decidim_category_id)
        end

        def parent
          @parent ||= Decidim::Accountability::Result.find_by(component: current_component, id: parent_id)
        end

        def status
          @status ||= Decidim::Accountability::Status.find_by(component: current_component, id: decidim_accountability_status_id)
        end
      end
    end
  end
end
