# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      paths["db/migrate"] = nil
      # paths["lib/tasks"] = nil

      def load_seed
        nil
      end
    end
  end
end
