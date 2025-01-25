# frozen_string_literal: true

module Decidim
  module Sortitions
    module SortitionsHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper

      def proposal_path(proposal)
        EngineRouter.main_proxy(proposal.component).proposal_path(proposal)
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.sortitions.name")
      end

      # Generates the sortition taxonomy labels
      def sortition_taxonomy_labels(sortition)
        if sortition.taxonomies.present?
          return I18n.t("show.taxonomies",
                        scope: "decidim.sortitions.sortitions",
                        taxonomies: sortition.taxonomies.map { |taxonomy| decidim_sanitize_translated(taxonomy.name) }.join(", "))
        end

        I18n.t("show.any_taxonomy", scope: "decidim.sortitions.sortitions")
      end

      # Show list of candidate proposals for a sortition. Selected sortition ids will appear with bold font.
      def sortition_proposal_candidate_ids(sortition)
        result = sortition.candidate_proposals.map do |proposal_id|
          if sortition.selected_proposals.include? proposal_id
            "<b>#{proposal_id}</b>"
          else
            proposal_id.to_s
          end
        end

        result.join(" - ").html_safe
      end

      def filter_sections_sortitions
        sections = [{ method: :with_any_state, collection: filter_state_values, label: t("decidim.sortitions.sortitions.filters.state"), id: "state" }]
        current_component.available_taxonomy_filters.each do |taxonomy_filter|
          sections.append(method: :with_any_taxonomies,
                          collection: filter_taxonomy_values_for(taxonomy_filter),
                          label: decidim_sanitize_translated(taxonomy_filter.name),
                          id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}")
        end
        sections.reject { |item| item[:collection].blank? }
      end

      def filter_state_values
        [
          ["all", t("all", scope: "decidim.sortitions.sortitions.filters")],
          ["active", t("active", scope: "decidim.sortitions.sortitions.filters")],
          ["cancelled", t("cancelled", scope: "decidim.sortitions.sortitions.filters")]
        ]
      end
    end
  end
end
