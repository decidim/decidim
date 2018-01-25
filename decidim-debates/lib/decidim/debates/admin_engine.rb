# frozen_string_literal: true

module Decidim
  module Debates
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Debates::Admin

      paths["db/migrate"] = nil

      routes do
        resources :debates
        root to: "debates#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_debates.inject_admin_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::Debates::Abilities::Admin::AdminAbility",
            "Decidim::Debates::Abilities::Admin::ParticipatoryProcessAdminAbility",
            "Decidim::Debates::Abilities::Admin::ParticipatoryProcessModeratorAbility"
          ]
        end
      end
    end
  end
end
