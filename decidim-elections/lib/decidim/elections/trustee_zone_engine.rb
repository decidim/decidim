# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface for trustees of `decidim-elections`.
    # It mostly handles rendering the trustees frontend zone.
    class TrusteeZoneEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::TrusteeZone

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resource :trustee, path: "/", only: [:show, :update] do
          resources :election, only: [] do
            resource :elections, only: [:show, :update]
          end
        end
      end

      def load_seed
        nil
      end

      initializer "decidim_elections.trustee_zone.menu" do
        Decidim.menu :user_menu do |menu|
          menu.item I18n.t("menu.trustee_zone", scope: "decidim.elections.trustee_zone"),
                    decidim.decidim_elections_trustee_zone_path,
                    active: :inclusive,
                    if: Decidim::Elections::Trustee.trustee?(current_user)
        end
      end
    end
  end
end
