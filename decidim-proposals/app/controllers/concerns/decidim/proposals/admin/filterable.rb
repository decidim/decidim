# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          helper Decidim::Proposals::Admin::FilterableHelper

          private

          # Comment about participatory_texts_enabled.
          def base_query
            return collection.order(:position) if current_component.settings.participatory_texts_enabled?

            accessible_proposals_collection
          end

          def accessible_proposals_collection
            return collection if current_participatory_space.user_roles(:valuator).where(user: current_user).empty?

            collection.with_valuation_assigned_to(current_user, current_participatory_space)
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def filters
            [
              :is_emendation_true,
              :state_eq,
              :state_null,
              :scope_id_eq,
              :category_id_eq,
              :valuator_role_ids_has
            ]
          end

          def filters_with_values
            {
              is_emendation_true: %w(true false),
              state_eq: proposal_states,
              scope_id_eq: scope_ids_hash(scopes.top_level),
              category_id_eq: category_ids_hash(categories.first_class),
              valuator_role_ids_has: valuator_role_ids
            }
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:scope_id_eq, :category_id_eq, :valuator_role_ids_has]
          end

          def valuator_role_ids
            current_participatory_space.user_roles(:valuator).pluck(:id)
          end

          def translated_valuator_role_ids_has(valuator_role_id)
            user_role = current_participatory_space.user_roles(:valuator).find_by(id: valuator_role_id)
            user_role&.user&.name
          end

          # An Array<Symbol> of possible values for `state_eq` filter.
          # Excludes the states that cannot be filtered with the ransack predicate.
          # A link to filter by "Not answered" will be added in:
          # Decidim::Proposals::Admin::FilterableHelper#extra_dropdown_submenu_options_items
          def proposal_states
            Proposal::POSSIBLE_STATES.without("not_answered")
          end
        end
      end
    end
  end
end
