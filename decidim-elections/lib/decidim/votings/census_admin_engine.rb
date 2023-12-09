# frozen_string_literal: true

require "decidim/votings/census_menu"

module Decidim
  module Votings
    class CensusEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Census::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      initializer "decidim_votings_census.admin_voting_menu" do
        Decidim::Votings::CensusMenu.register_admin_voting_menu!
      end
    end
  end
end
