# frozen_string_literal: true

module Decidim
  module Surveys
    # This is the engine that runs on the public interface of `Surveys`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Surveys::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        put "/", to: "surveys#update", as: :survey
        root to: "surveys#edit"
      end

      initializer "decidim.notifications.components" do
        Decidim::EventsManager.subscribe(/^decidim\.events\.components/) do |event_name, data|
          CleanSurveyAnswersJob.perform_later(event_name, data)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
