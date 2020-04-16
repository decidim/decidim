# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This is the engine that runs on the public interface of `decidim-budgets` groups.
      # It mostly handles the manage of the budgets included in it.
      # process.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Budgets::Groups::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          root to: "budgets#index"
        end
      end
    end
  end
end
