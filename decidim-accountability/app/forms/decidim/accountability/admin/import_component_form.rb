# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A form object to be used when admin users want to import results from
      # another component into Accountability component.
      class ImportComponentForm < Decidim::Form
        include Decidim::TranslatableAttributes
        include Decidim::HasTaxonomyFormAttributes

        attribute :origin_component_id, Integer
        attribute :proposal_state_id, Integer

        validates :origin_component_id, presence: true
        validates :filtered_items_count, numericality: { greater_than: 0 }, if: ->(form) { form.origin_component_id }

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where(manifest_name: %w(budgets proposals))
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def proposal_states_collection
          Decidim::Proposals::ProposalState.where(component: origin_component).map do |state|
            [translated_attribute(state.title), state.id]
          end
        end

        delegate :count, to: :filtered_items, prefix: true

        def filtered_items
          if origin_component.manifest_name == "budgets"
            filtered_budget_projects
          elsif origin_component.manifest_name == "proposals"
            filtered_proposals
          else
            raise "Invalid component"
          end
        end

        def project_already_copied?(original_project)
          original_project.linked_resources(:results, "included_projects").any? do |result|
            result.component == current_component
          end
        end

        def proposal_already_copied?(original_proposal)
          original_proposal.linked_resources(:results, "included_proposals").any? do |result|
            result.component == current_component
          end
        end

        private

        def filtered_budget_projects
          scope = Decidim::Budgets::Project.joins(:budget).selected.where(budget: { component: origin_component })
          scope = filter_taxonomies(scope)
          scope.reject { |project| project_already_copied?(project) }
        end

        def filtered_proposals
          scope = Decidim::Proposals::Proposal.where(component: origin_component).not_hidden
          scope = scope.where(decidim_proposals_proposal_state_id: proposal_state_id) if proposal_state_id
          scope = filter_taxonomies(scope)
          scope.reject { |proposal| proposal_already_copied?(proposal) }
        end

        def filter_taxonomies(scope)
          if taxonomy_sets.any?
            scope.with_any_taxonomies(*taxonomy_sets)
          else
            scope
          end
        end

        def taxonomy_sets
          @taxonomy_sets ||= taxonomies.compact.map do |taxonomy_id|
            taxonomy = Decidim::Taxonomy.find(taxonomy_id)
            root_taxonomy_id = taxonomy.root_taxonomy.id

            return nil if !root_taxonomy_id || !taxonomy_id

            [root_taxonomy_id, [taxonomy_id]]
          end.compact
        end
      end
    end
  end
end
