# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `decidim-elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      def load_seed
        nil
      end
    end
  end
end
