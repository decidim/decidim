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
            query =
              collection
              # Includes the presided and managed polling station
              .joins("LEFT JOIN decidim_votings_polling_stations presided_station ON decidim_votings_polling_officers.presided_polling_station_id = presided_station.id
                      LEFT JOIN decidim_votings_polling_stations managed_station ON decidim_votings_polling_officers.managed_polling_station_id = managed_station.id
                      LEFT JOIN decidim_users ON decidim_users.id = decidim_votings_polling_officers.decidim_user_id")

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
