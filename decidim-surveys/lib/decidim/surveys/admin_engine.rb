# frozen_string_literal: true
module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil

      routes do
        # Add admin engine routes here
        # resources :surveys do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "surveys#index"
      end

      initializer "decidim_surveys.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += ["Decidim::Surveys::Abilities::AdminUser"]
          config.admin_abilities += ["Decidim::Surveys::Abilities::ProcessAdminUser"]
        end
      end

      def load_seed
        nil
      end
    end
  end
end
