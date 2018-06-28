# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module ParticipatoryProcesses
    # Decidim's Participatory Processes Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcesses

      routes do
        get "processes/:process_id", to: redirect { |params, _request|
          process = Decidim::ParticipatoryProcess.find(params[:process_id])
          process ? "/processes/#{process.slug}" : "/404"
        }, constraints: { process_id: /[0-9]+/ }

        get "/processes/:process_id/f/:component_id", to: redirect { |params, _request|
          process = Decidim::ParticipatoryProcess.find(params[:process_id])
          process ? "/processes/#{process.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { process_id: /[0-9]+/ }

        resources :participatory_process_groups, only: :show, path: "processes_groups"
        resources :participatory_processes, only: [:index, :show], param: :slug, path: "processes" do
          resources :participatory_process_steps, only: [:index], path: "steps"
          resource :participatory_process_widget, only: :show, path: "embed"
        end

        scope "/processes/:participatory_process_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_participatory_process_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_participatory_processes.assets" do |app|
        app.config.assets.precompile += %w(decidim_participatory_processes_manifest.js)
      end

      initializer "decidim_participatory_processes.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcesses::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcesses::Engine.root}/app/views") # for partials
      end

      initializer "decidim_participatory_processes.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.processes", scope: "decidim"),
                    decidim_participatory_processes.participatory_processes_path,
                    position: 2,
                    if: Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?,
                    active: /^\/process(es|_groups)/
        end
      end

      initializer "decidim_participatory_processes.view_hooks" do
        Decidim.view_hooks.register(:highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          highlighted_processes =
            OrganizationPublishedParticipatoryProcesses.new(view_context.current_organization, view_context.current_user) |
            HighlightedParticipatoryProcesses.new |
            FilteredParticipatoryProcesses.new("active")

          next unless highlighted_processes.any?

          view_context.render(
            partial: "decidim/participatory_processes/pages/home/highlighted_processes",
            locals: {
              highlighted_processes: highlighted_processes
            }
          )
        end
      end
    end
  end
end
