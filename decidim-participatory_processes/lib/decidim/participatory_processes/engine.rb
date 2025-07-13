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

        resources :participatory_process_groups, only: :show, path: "processes_groups"
        resources :participatory_processes, only: [:index, :show], param: :slug, path: "processes" do
          resources :participatory_space_private_users, only: :index, path: "members"
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

      initializer "decidim_participatory_processes.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ParticipatoryProcesses::Engine, at: "/", as: "decidim_participatory_processes"
        end
      end

      initializer "decidim_participatory_processes.register_icons" do
        Decidim.icons.register(name: "Decidim::ParticipatoryProcess", icon: "treasure-map-line", description: "Participatory Process", category: "activity",
                               engine: :participatory_process)
        Decidim.icons.register(name: "Decidim::ParticipatoryProcessGroup", icon: "treasure-map-line", description: "Participatory Process Group", category: "activity",
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
        Decidim::ParticipatoryProcesses::Menu.register_mobile_menu!
        Decidim::ParticipatoryProcesses::Menu.register_home_content_block_menu!
      end

      initializer "decidim_participatory_processes.content_blocks" do
        Decidim::ParticipatoryProcesses::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_participatory_processes.stats" do
        Decidim.stats.register :processes_count,
                               priority: StatsRegistry::HIGH_PRIORITY,
                               icon_name: "treasure-map-line",
                               tooltip_key: "processes_count_tooltip" do |organization, start_at, end_at|
          processes = ParticipatoryProcesses::OrganizationPrioritizedParticipatoryProcesses.new(organization)

          processes = processes.where(created_at: start_at..) if start_at.present?
          processes = processes.where(created_at: ..end_at) if end_at.present?
          processes.count
        end

        Decidim.stats.register :followers_count,
                               priority: StatsRegistry::MEDIUM_PRIORITY,
                               icon_name: "user-follow-line",
                               tooltip_key: "followers_count_tooltip" do |participatory_space|
          Decidim::ParticipatoryProcesses::ParticipatoryProcessesStatsFollowersCount.for(participatory_space)
        end

        Decidim.stats.register :participants_count,
                               priority: StatsRegistry::MEDIUM_PRIORITY,
                               icon_name: "user-line",
                               tooltip_key: "participants_count_tooltip" do |participatory_space|
          Decidim::ParticipatoryProcesses::ParticipatoryProcessesStatsParticipantsCount.for(participatory_space)
        end
      end

      initializer "decidim_participatory_processes.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
