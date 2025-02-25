# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This is the engine that runs on the public interface of `decidim-collaborative_texts`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CollaborativeTexts::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      # routes ...

      def load_seed
        nil
      end
    end
  end
end
