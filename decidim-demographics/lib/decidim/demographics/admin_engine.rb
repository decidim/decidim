# frozen_string_literal: true

module Decidim
  module Demographics
    # This is the engine that runs on the public interface of `Demographics`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Demographics::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        root to: "demographics#index"
      end

      def load_seed
        nil
      end
    end
  end
end
