# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        post "/", to: "surveys#update", as: :survey
        root to: "surveys#edit"
      end

      initializer "decidim_surveys.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_surveys_manifest.js)
      end

      def load_seed
        nil
      end
    end
  end
end
