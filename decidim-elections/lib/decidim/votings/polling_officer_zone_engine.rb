# frozen_string_literal: true

module Decidim
  module Votings
    # This is the engine that runs on the public interface for polling officers of `decidim-elections`.
    # It mostly handles rendering the polling officers frontend zone.
    class PollingOfficerZoneEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::PollingOfficerZone

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resource :polling_officers, path: "/", only: [:show] do
          resources :polling_stations, only: [:show]
        end
      end

      def load_seed
        nil
      end

      initializer "decidim_elections.polling_officer_zone.menu" do
        Decidim.menu :user_menu do |menu|
          menu.item I18n.t("menu.polling_officer_zone", scope: "decidim.votings.polling_officer_zone"),
                    decidim.decidim_votings_polling_officer_zone_path,
                    active: :inclusive,
                    if: Decidim::Votings::PollingOfficer.polling_officer?(current_user)
        end
      end
    end
  end
end
