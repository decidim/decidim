# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CollaborativeTexts

      paths["db/migrate"] = nil

      def load_seed
        nil
      end
    end
  end
end
