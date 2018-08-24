# frozen_string_literal: true

require "searchlight"
require "kaminari"

module Decidim
  module Accountability
    # This is the engine that runs on the public interface of `decidim-accountability`.
    # It mostly handles rendering the created results associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Accountability

      routes do
        resources :results, only: [:index, :show] do
          resource :result_widget, only: :show, path: "embed"
          resources :versions, only: [:show, :index]
        end
        root to: "results#home"
      end

      initializer "decidim_accountability.assets" do |app|
        app.config.assets.precompile += %w(decidim_accountability_manifest.js)
      end

      initializer "decidim_accountability.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::LOW_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          results = Decidim::Accountability::Result.where(component: published_components).order_randomly(rand * 2 - 1).limit(4)

          next unless results.any?

          view_context.extend Decidim::Accountability::ApplicationHelper
          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_results",
            locals: {
              results: results
            }
          )
        end

        if defined? Decidim::ParticipatoryProcesses
          Decidim::ParticipatoryProcesses.view_hooks.register(:process_group_highlighted_elements, priority: Decidim::ViewHooks::LOW_PRIORITY) do |view_context|
            published_components = Decidim::Component.where(participatory_space: view_context.participatory_processes).published
            results = Decidim::Accountability::Result.where(component: published_components).order_randomly(rand * 2 - 1).limit(4)

            next unless results.any?

            view_context.extend Decidim::Accountability::ApplicationHelper
            view_context.render(
              partial: "decidim/participatory_processes/participatory_process_groups/highlighted_results",
              locals: {
                results: results
              }
            )
          end
        end
      end
    end
  end
end
