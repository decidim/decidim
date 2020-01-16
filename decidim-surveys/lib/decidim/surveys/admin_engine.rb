# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/answer/:session_token", to: "surveys#show", as: :show_survey
        get "/answers", to: "surveys#index", as: :index_survey
        put "/", to: "surveys#update", as: :survey
        root to: "surveys#edit"
      end

      def load_seed
        nil
      end
    end
  end
end
