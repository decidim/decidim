# frozen_string_literal: true

require "decidim/votings/menu"

module Decidim
  module Votings
    # This is the engine that runs on the public interface for polling officers of `decidim-elections`.
    # It mostly handles rendering the polling officers frontend zone.
    class PollingOfficerZoneEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::PollingOfficerZone

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :polling_officers, path: "/", only: [:index] do
          resources :elections, only: [:index] do
            resource :closure do
              member do
                post :certify
                post :sign
              end
            end
            resources :in_person_votes, only: [:new, :create, :show, :update]
          end
        end
      end

      def load_seed
        nil
      end

      initializer "decidim_elections.polling_officer_zone.menu" do
        Decidim::Votings::Menu.register_user_menu!
      end
    end
  end
end
