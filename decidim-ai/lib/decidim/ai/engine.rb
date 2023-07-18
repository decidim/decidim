# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      paths["db/migrate"] = nil
      # paths["lib/tasks"] = nil

      initializer "decidim_ai.classifiers" do |_app|
        Decidim::Ai.registered_analyzers.each do |analyzer|
          Decidim::Ai.spam_detection_registry.register_analyzer(**analyzer)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
