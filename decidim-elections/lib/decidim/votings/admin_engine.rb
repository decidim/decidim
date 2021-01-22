# frozen_string_literal: true

module Decidim
  module Votings
    # Decidim's Votings Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings, param: :slug, except: [:show, :destroy]
      end

      initializer "decidim_votings.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.votings", scope: "decidim.votings.admin"),
                    decidim_admin_votings.votings_path,
                    icon_name: "comment-square",
                    position: 3.7,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :votings)
        end
      end
    end
  end
end
