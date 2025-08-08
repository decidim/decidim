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

          delegate :filters, :dynamically_translated_filters, :filters_with_values, to: :filter_config

          # Comment about participatory_texts_enabled.
          def base_query
            return collection.order(:position) if current_component.settings.participatory_texts_enabled?

            return accessible_proposals_collection unless taxonomy_order_or_search?

            # this is a trick to avoid duplicates when using search in associations as suggested in:
            # https://activerecord-hackery.github.io/ransack/going-further/other-notes/#problem-with-distinct-selects
            accessible_proposals_collection.includes(:taxonomies).joins(:taxonomies)
          end

          def accessible_proposals_collection
            return collection if current_participatory_space.user_roles(:evaluator).where(user: current_user).empty?

            collection.with_evaluation_assigned_to(current_user, current_participatory_space)
          end

          def search_field_predicate
            :id_string_or_title_cont
          end

          def filter_config
            @filter_config ||= Decidim::AdminFilter.new(:proposals).build_for(self)
          end

          def translated_state_eq(state)
            return t("decidim.admin.filters.proposals.state_eq.values.withdrawn") if state == "withdrawn"

            translated_attribute(ProposalState.where(component: current_component, token: state).first&.title)
          end

          def state_eq_values
            ProposalState.where(component: current_component).pluck(:token) + ["withdrawn"]
          end

          def evaluator_role_ids
            current_participatory_space.user_roles(:evaluator).order_by_name.pluck(:id)
          end

          def translated_evaluator_role_ids_has(evaluator_role_id)
            user_role = current_participatory_space.user_roles(:evaluator).find_by(id: evaluator_role_id)
            user_role&.user&.name
          end
        end
      end
    end
  end
end
