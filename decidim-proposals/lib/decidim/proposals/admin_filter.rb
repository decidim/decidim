# frozen_string_literal: true

module Decidim
  module Proposals
    class AdminFilter
      def self.register_filter!
        Decidim.admin_filter(:proposals) do |configuration|
          configuration.add_filters(
            :is_emendation_true,
            :state_eq,
            :with_any_state,
            :scope_id_eq,
            :category_id_eq,
            :valuator_role_ids_has
          )

          configuration.add_filters_with_values(
            is_emendation_true: %w(true false),
            state_eq: state_eq_values,
            with_any_state: %w(state_published state_not_published),
            scope_id_eq: scope_ids_hash(scopes.top_level),
            category_id_eq: category_ids_hash(categories.first_class),
            valuator_role_ids_has: valuator_role_ids
          )

          configuration.add_dynamically_translated_filters(
            :scope_id_eq,
            :category_id_eq,
            :valuator_role_ids_has,
            :proposal_state_id_eq,
            :state_eq
          )
        end
      end
    end
  end
end
