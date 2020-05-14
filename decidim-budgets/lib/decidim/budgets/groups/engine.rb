# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This is the engine that runs on the public interface of `decidim-budgets` groups.
      # It mostly handles rendering the list of budgets included in it.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Budgets::Groups

        paths["lib/tasks"] = nil

        routes do
          root to: "budgets#index"
        end

        initializer "decidim_budgets.groups.view_hooks" do
          Decidim.view_hooks.register(:budgets_parent_information, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
            view_context.render(
              partial: "decidim/budgets/groups/hooks/more_information_modal"
            )
          end
        end
      end
    end
  end
end
