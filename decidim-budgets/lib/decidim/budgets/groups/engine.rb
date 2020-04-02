# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This is the engine that runs on the public interface of `decidim-budgets` groups.
      # It mostly handles rendering the list of budgets included in it.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Budgets::Groups

        routes do
          root to: "budgets#index"
        end
      end
    end
  end
end
