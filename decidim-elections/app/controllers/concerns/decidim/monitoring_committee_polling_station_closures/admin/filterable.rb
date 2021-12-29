# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module MonitoringCommitteePollingStationClosures
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            # Includes the officers (president and managers) and their correspective decidim users when they(=officers) are present
            query =
              collection
              .joins("LEFT JOIN decidim_votings_polling_officers president ON president.presided_polling_station_id = decidim_votings_polling_stations.id
                      LEFT JOIN decidim_users president_user ON president_user.id = president.decidim_user_id
                      LEFT JOIN decidim_votings_polling_officers managers ON managers.managed_polling_station_id = decidim_votings_polling_stations.id
                      LEFT JOIN decidim_users manager_user ON manager_user.id = managers.decidim_user_id
                      LEFT JOIN decidim_votings_polling_station_closures closure ON closure.decidim_votings_polling_station_id = decidim_votings_polling_stations.id
                        AND closure.decidim_elections_election_id = #{election_id}")

            query = filter_by_validated(query)
            filter_by_signed(query)
          end

          def election_id
            params[:election_id]
          end

          def search_field_predicate
            :title_or_address_or_manager_name_or_manager_email_or_manager_nickname_or_president_name_or_president_email_or_president_nickname_cont
          end

          def extra_allowed_params
            [:election_id, :per_page]
          end

          def filters
            [:validated_eq, :signed_eq]
          end

          def filter_by_validated(query)
            case ransack_params[:validated_eq]
            when "false"
              query.where(Arel.sql("closure.validated_at IS NOT NULL"))
            when "true"
              query.where(Arel.sql("closure.validated_at IS NULL"))
            else
              query
            end
          end

          def filter_by_signed(query)
            case ransack_params[:signed_eq]
            when "false"
              query.where(Arel.sql("closure.signed_at IS NOT NULL"))
            when "true"
              query.where(Arel.sql("closure.signed_at IS NULL"))
            else
              query
            end
          end
        end
      end
    end
  end
end
