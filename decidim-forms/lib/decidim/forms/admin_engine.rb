# frozen_string_literal: true

module Decidim
  module Forms
    # This is the engine that runs on the public interface of `Forms`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Forms::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      def load_seed
        nil
      end
    end
  end
end
