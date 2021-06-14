# frozen_string_literal: true

module Decidim
  module Votings
    class CensusEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Census

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      # routes do
      # end

      def load_seed
        nil
      end
    end
  end
end
