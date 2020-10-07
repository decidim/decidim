# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component into projects component.
      class ProjectImportProposalsForm < Decidim::Form
        mimic :proposals_import

        attribute :origin_component_id, Integer
        attribute :scope_id, Integer
        attribute :default_budget, Integer
        attribute :import_all_accepted_proposals, Boolean

        validates :origin_component_id, :origin_component, :current_component, presence: true
        validates :import_all_accepted_proposals, allow_nil: false, acceptance: true
        validates :default_budget, presence: true, numericality: { greater_than: 0 }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
        validates :scope_id, scope_belongs_to_component: true, if: ->(form) { form.scope_id.present? }

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where(manifest_name: :proposals)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def scope
          @scope ||= @scope_id ? current_component.scopes.find_by(id: @scope_id) : current_component.scope
        end

        def scope_id
          @scope_id || scope&.id
        end

        def budget
          @budget ||= context[:budget]
        end
      end
    end
  end
end
