# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update projects from Decidim's admin panel.
      class ProjectForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper
        include Decidim::ApplicationHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :budget_amount, Integer
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer
        attribute :proposal_ids, Array[Integer]
        attribute :attachment, AttachmentForm
        attribute :photos, Array[String]
        attribute :add_photos, Array

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :budget_amount, presence: true, numericality: { greater_than: 0 }

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }

        validate :scope_belongs_to_participatory_space_scope

        validate :notify_missing_attachment_if_errored

        delegate :categories, to: :current_component

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)

          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, current_component)
                         &.where(id: proposal_ids)
                         &.order(title: :asc)
        end

        # Finds the Budget from the decidim_budgets_budget_id.
        #
        # Returns a Decidim::Budgets:Budget
        def budget
          @budget ||= context[:budget]
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

        # This method will add an error to the `attachment` field only if there's
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
