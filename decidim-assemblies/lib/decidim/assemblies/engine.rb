# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "decidim/assemblies/query_extensions"
require "decidim/assemblies/content_blocks/registry_manager"
require "decidim/assemblies/menu"

module Decidim
  module Assemblies
    # Decidim's Assemblies Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Assemblies

      routes do
        extend Decidim::Routes::LocaleRedirects

        scope "/:locale", **locale_scope_options do
          get "assemblies/:assembly_id", to: redirect { |params, _request|
            assembly = Decidim::Assembly.find(params[:assembly_id])
            assembly ? "/#{params[:locale]}/assemblies/#{assembly.slug}" : "/404"
          }, constraints: { assembly_id: /[0-9]+/ }

          get "/assemblies/:assembly_id/f/:component_id", to: redirect { |params, _request|
            assembly = Decidim::Assembly.find(params[:assembly_id])
            assembly ? "/#{params[:locale]}/assemblies/#{assembly.slug}/f/#{params[:component_id]}" : "/404"
          }, constraints: { assembly_id: /[0-9]+/ }

          resources :assemblies, only: [:index, :show], param: :slug, path: "assemblies" do
            resources :members, only: :index, path: "members"
          end

          scope "/assemblies/:assembly_slug/f/:component_id" do
            Decidim.component_manifests.each do |manifest|
              next unless manifest.engine

              constraints CurrentComponent.new(manifest) do
                mount manifest.engine, at: "/", as: "decidim_assembly_#{manifest.name}"
              end
            end
          end
        end

        get "/assemblies", to: redirect(&locale_redirector("/assemblies"))

        get "/assemblies/*rest", to: redirect { |params, request| locale_redirector("/assemblies/#{params[:rest]}").call(params, request) }
      end

      initializer "decidim_assemblies.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Assemblies::Engine, at: "/", as: "decidim_assemblies"
        end
      end

      initializer "decidim_assemblies.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end

      initializer "decidim_assemblies.register_icons" do
        Decidim.icons.register(name: "Decidim::Assembly", icon: "government-line", description: "Assembly", category: "activity", engine: :assemblies)
        Decidim.icons.register(name: "group-2-line", icon: "group-2-line", category: "system", description: "", engine: :assemblies)
      end

      initializer "decidim_assemblies.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Assemblies::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Assemblies::Engine.root}/app/views") # for partials
      end

      initializer "decidim_assemblies.stats" do
        Decidim.stats.register :assemblies_count,
                               priority: StatsRegistry::HIGH_PRIORITY,
                               icon_name: "government-line",
                               tooltip_key: "assemblies_count_tooltip" do |organization, _start_at, _end_at|
          Decidim::Assembly.where(organization:).public_spaces.count
        end
      end

      initializer "decidim_assemblies.menu" do
        Decidim::Assemblies::Menu.register_menu!
        Decidim::Assemblies::Menu.register_mobile_menu!
        Decidim::Assemblies::Menu.register_home_content_block_menu!
      end

      initializer "decidim_assemblies.content_blocks" do
        Decidim::Assemblies::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_assemblies.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Assemblies::QueryExtensions
      end

      initializer "decidim_assemblies.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_assemblies.extend_component_controllers" do
        config.to_prepare do
          # Extend component controllers with assembly breadcrumb when mounted under assemblies
          Decidim::Components::BaseController.include(Decidim::Assemblies::AssemblyBreadcrumb)
        end
      end
    end
  end
end
