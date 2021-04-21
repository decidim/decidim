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
            collection
              # Includes the officers (president and managers) and their correspective decidim users when they(=officers) are present
              .joins("LEFT JOIN decidim_votings_polling_officers president ON president.presided_polling_station_id = decidim_votings_polling_stations.id
                      LEFT JOIN decidim_users president_user ON president_user.id = president.decidim_user_id
                      LEFT JOIN decidim_votings_polling_officers managers ON managers.managed_polling_station_id = decidim_votings_polling_stations.id
                      LEFT JOIN decidim_users manager_user ON manager_user.id = managers.decidim_user_id")
          end

          def search_field_predicate
            :title_or_address_or_manager_name_or_manager_email_or_manager_nickname_or_president_name_or_president_email_or_president_nickname_cont
          end

          def extra_allowed_params
            [:election_id, :per_page]
          end

          def filters
            [:verified_at_null]
          end
        end
      end
    end
  end
end
