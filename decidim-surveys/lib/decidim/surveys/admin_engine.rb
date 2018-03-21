# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil

      routes do
        post "/", to: "surveys#update", as: :survey
        root to: "surveys#edit"
      end

      initializer "decidim_surveys.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_surveys_manifest.js)
      end

      initializer "decidim_surveys.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::Surveys::Abilities::AdminAbility",
            "Decidim::Surveys::Abilities::ParticipatoryProcessAdminAbility"
          ]
        end
      end

      def load_seed
        nil
      end
    end
  end
end
