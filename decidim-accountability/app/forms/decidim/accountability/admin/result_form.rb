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
        attribute :start_date, Date
        attribute :end_date, Date
        attribute :progress, Float
        attribute :decidim_accountability_status_id, Integer
        attribute :parent_id, Integer

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true

        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        validates :parent, presence: true, if: ->(form) { form.parent_id.present? }
        validates :status, presence: true, if: ->(form) { form.decidim_accountability_status_id.present? }

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)
          self.decidim_category_id = model.category.try(:id)
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, context.current_feature)&.order(title: :asc)&.pluck(:title, :id)
        end

        def participatory_space_scope
          current_feature.participatory_space.scope
        end

        alias feature current_feature

        # Finds the Scope from the decidim_scope_id.
        #
        # Returns a Decidim::Scope
        def scope
          return unless current_feature && decidim_scope_id
          @scope ||= current_feature.scopes.where(id: decidim_scope_id).first
        end

        # Proposal scope_id, uses process scope if missing.
        #
        # Returns the scope identifier related to the result
        def decidim_scope_id
          @decidim_scope_id || participatory_space_scope&.id
        end

        def category
          @category ||= context.current_feature.categories.where(id: decidim_category_id).first
        end

        def parent
          @parent ||= Decidim::Accountability::Result.where(feature: current_feature, id: parent_id).first
        end

        def status
          @status ||= Decidim::Accountability::Status.where(feature: current_feature, id: decidim_accountability_status_id).first
        end
      end
    end
  end
end
