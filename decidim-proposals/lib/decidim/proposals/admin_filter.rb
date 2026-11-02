# frozen_string_literal: true

module Decidim
  module Proposals
    class AdminFilter
      def self.register_filter!
        Decidim.admin_filter(:proposals) do |configuration|
          configuration.add_filters(
            :is_emendation_true,
            :status_eq,
            :with_any_status,
            :taxonomies_part_of_contains,
            :evaluator_role_ids_has
          )

          configuration.add_filters_with_values(
            is_emendation_true: %w(true false),
            status_eq: status_eq_values,
            with_any_status: %w(status_published status_not_published),
            taxonomies_part_of_contains: taxonomy_ids_hash(available_root_taxonomies),
            evaluator_role_ids_has: evaluator_role_ids
          )

          configuration.add_dynamically_translated_filters(
            :evaluator_role_ids_has,
            :proposal_status_id_eq,
            :taxonomies_part_of_contains,
            :status_eq
          )
        end
      end
    end
  end
end
