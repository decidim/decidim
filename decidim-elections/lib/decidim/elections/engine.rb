# frozen_string_literal: true

module Decidim
  module Elections
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      paths["db/migrate"] = nil

      def load_seed
        nil
      end
    end
  end
end
