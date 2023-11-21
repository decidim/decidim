# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "decidim/participatory_processes/menu"
require "decidim/participatory_processes/content_blocks/registry_manager"
require "decidim/participatory_processes/query_extensions"

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

        get "processes/:process_id/all-metrics", to: redirect { |params, _request|
          process = Decidim::ParticipatoryProcess.find(params[:process_id])
          process ? "/processes/#{process.slug}/all-metrics" : "/404"
        }, constraints: { process_id: /[0-9]+/ }, as: :all_metrics

        resources :participatory_process_groups, only: :show, path: "processes_groups"
        resources :participatory_processes, only: [:index, :show], param: :slug, path: "processes" do
          get "all-metrics", on: :member
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

      initializer "decidim_participatory_processes.register_icons" do
        Decidim.icons.register(name: "Decidim::ParticipatoryProcess", icon: "treasure-map-line", description: "Participatory Process", category: "activity",
                               engine: :participatory_process)
        Decidim.icons.register(name: "Decidim::ParticipatoryProcess", icon: "treasure-map-line", category: "activity",
                               description: "Participatory Process", engine: :participatory_process)

        Decidim.icons.register(name: "drag-move-2-line", icon: "drag-move-2-line", category: "system", description: "",
                               engine: :participatory_process)
        Decidim.icons.register(name: "archive-line", icon: "archive-line", category: "system", description: "", engine: :participatory_process)
        Decidim.icons.register(name: "grid-line", icon: "grid-line", category: "system", description: "", engine: :participatory_process)
        Decidim.icons.register(name: "globe-line", icon: "globe-line", category: "system", description: "", engine: :participatory_process)
      end

      initializer "decidim_participatory_processes.query_extensions" do
        Decidim::Api::QueryType.include Decidim::ParticipatoryProcesses::QueryExtensions
      end

      initializer "decidim_participatory_processes.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcesses::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcesses::Engine.root}/app/views") # for partials
      end

      initializer "decidim_participatory_processes.menu" do
        Decidim::ParticipatoryProcesses::Menu.register_menu!
        Decidim::ParticipatoryProcesses::Menu.register_home_content_block_menu!
      end

      initializer "decidim_participatory_processes.content_blocks" do
        Decidim::ParticipatoryProcesses::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_participatory_processes.stats" do
        Decidim.stats.register :followers_count, priority: StatsRegistry::HIGH_PRIORITY do |participatory_space|
          Decidim::ParticipatoryProcesses::StatsFollowersCount.for(participatory_space)
        end

        Decidim.stats.register :participants_count, priority: StatsRegistry::HIGH_PRIORITY do |participatory_space|
          Decidim::ParticipatoryProcesses::StatsParticipantsCount.for(participatory_space)
        end
      end

      initializer "decidim_participatory_processes.register_metrics" do
        Decidim.metrics_registry.register(:participatory_processes) do |metric_registry|
          metric_registry.manager_class = "Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessesMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home)
            settings.attribute :weight, type: :integer, default: 2
          end
        end

        Decidim.metrics_operation.register(:followers, :participatory_process) do |metric_operation|
          metric_operation.manager_class = "Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessFollowersMetricMeasure"
        end
      end

      initializer "decidim_participatory_processes.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
