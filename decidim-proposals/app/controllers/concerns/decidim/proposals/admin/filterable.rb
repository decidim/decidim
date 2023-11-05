# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

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
              :proposal_state_id_eq,
              :scope_id_eq,
              :category_id_eq,
              :valuator_role_ids_has
            ]
          end

          def filters_with_values
            {
              is_emendation_true: %w(true false),
              proposal_state_id_eq: proposal_state_ids,
              scope_id_eq: scope_ids_hash(scopes.top_level),
              category_id_eq: category_ids_hash(categories.first_class),
              valuator_role_ids_has: valuator_role_ids
            }
          end

          # Cannot user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:scope_id_eq, :category_id_eq, :valuator_role_ids_has, :proposal_state_id_eq]
          end

          def proposal_state_ids
            ProposalState.where(component: current_component).pluck(:id)
          end

          def valuator_role_ids
            current_participatory_space.user_roles(:valuator).pluck(:id)
          end

          def translated_proposal_state_id_eq(state_id)
            translated_attribute(ProposalState.find_by(id: state_id)&.title)
          end

          def translated_valuator_role_ids_has(valuator_role_id)
            user_role = current_participatory_space.user_roles(:valuator).find_by(id: valuator_role_id)
            user_role&.user&.name
          end
        end
      end
    end
  end
end
