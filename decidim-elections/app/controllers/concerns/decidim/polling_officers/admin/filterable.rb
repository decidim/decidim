# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module PollingOfficers
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            query = Decidim::Votings::Admin::PollingOfficersJoinPollingStationsAndUser.for(collection)

            filter_by_role(query)
          end

          def search_field_predicate
            :name_or_email_or_nickname_or_presided_station_title_or_managed_station_title_cont
          end

          def filters
            [
              :role_eq
            ]
          end

          def filters_with_values
            {
              role_eq: roles
            }
          end

          def roles
            [:president, :manager, :unassigned]
          end

          def filter_by_role(query)
            case ransack_params[:role_eq]
            when :president.to_s
              query.where(Arel.sql("presided_station.id IS NOT NULL"))
            when :manager.to_s
              query.where(Arel.sql("managed_station.id IS NOT NULL"))
            when :unassigned.to_s
              query.where(Arel.sql("presided_station.id IS NULL")).where(Arel.sql("managed_station.id IS NULL"))
            else
              query
            end
          end
        end
      end
    end
  end
end
