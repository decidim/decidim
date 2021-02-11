# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module PollingStations
      module Admin
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def base_query
              collection
                # Includes the officers (president and managers) and their correspective decidim users when they(=officers) are present
                .joins("LEFT JOIN decidim_votings_polling_officers ON
                        (decidim_votings_polling_officers.presided_polling_station_id = decidim_votings_polling_stations.id OR
                        decidim_votings_polling_officers.managed_polling_station_id = decidim_votings_polling_stations.id)
                        LEFT JOIN decidim_users ON
                        decidim_users.id = decidim_votings_polling_officers.decidim_user_id")
            end

            def search_field_predicate
              :title_or_officer_name_or_officer_email_or_officer_nickname_cont
            end

            def filters
              []
            end
          end
        end
      end
    end
  end
end
