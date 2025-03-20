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

            accessible_proposals_collection
          end

          def accessible_proposals_collection
            return collection if current_participatory_space.user_roles(:valuator).where(user: current_user).empty?

            collection.with_valuation_assigned_to(current_user, current_participatory_space)
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

          def valuator_role_ids
            current_participatory_space.user_roles(:valuator).order_by_name.pluck(:id)
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
