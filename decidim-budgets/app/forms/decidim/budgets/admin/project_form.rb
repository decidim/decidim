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

        attribute :budget, Integer
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer
        attribute :proposal_ids, Array[Integer]
        attribute :attachment, AttachmentForm
        attribute :photos, Array[String]
        attribute :add_photos, Array

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :budget, presence: true, numericality: { greater_than: 0 }

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :decidim_scope_id, scope_belongs_to_component: true, if: ->(form) { form.decidim_scope_id.present? }

        delegate :categories, to: :current_component

        alias component current_component

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)

          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, current_component)
                         &.published
                         &.order(title: :asc)
                         &.map { |proposal| [present(proposal).title, proposal.id] }
        end

        # Finds the Category from the decidim_category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.find_by(id: decidim_category_id)
        end

        # Finds the Scope from the given decidim_scope_id, uses current_component scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? current_component.scopes.find_by(id: @decidim_scope_id) : current_component.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the project
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end

        private

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
