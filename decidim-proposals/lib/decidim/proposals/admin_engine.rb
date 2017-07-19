# frozen_string_literal: true

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Proposals::Admin

      paths["db/migrate"] = nil

      routes do
        resources :proposals, only: [:index, :new, :create] do
          resources :proposal_answers, only: [:edit, :update]
        end

        root to: "proposals#index"
      end

      initializer "decidim_proposals.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::Proposals::Abilities::AdminAbility",
            "Decidim::Proposals::Abilities::ParticipatoryProcessAdminAbility",
            "Decidim::Proposals::Abilities::ParticipatoryProcessModeratorAbility"
          ]
        end
      end

      def load_seed
        nil
      end
    end
  end
end
