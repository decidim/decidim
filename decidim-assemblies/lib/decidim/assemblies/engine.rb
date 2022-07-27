# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "decidim/assemblies/query_extensions"

module Decidim
  module Assemblies
    # Decidim's Assemblies Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Assemblies

      routes do
        get "assemblies/:assembly_id", to: redirect { |params, _request|
          assembly = Decidim::Assembly.find(params[:assembly_id])
          assembly ? "/assemblies/#{assembly.slug}" : "/404"
        }, constraints: { assembly_id: /[0-9]+/ }

        get "/assemblies/:assembly_id/f/:component_id", to: redirect { |params, _request|
          assembly = Decidim::Assembly.find(params[:assembly_id])
          assembly ? "/assemblies/#{assembly.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { assembly_id: /[0-9]+/ }

        resources :assemblies, only: [:index, :show], param: :slug, path: "assemblies" do
          resources :assembly_members, only: :index, path: "members"
          resource :widget, only: :show, path: "embed"
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

      initializer "decidim_assemblies.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Assemblies::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Assemblies::Engine.root}/app/views") # for partials
      end

      initializer "decidim.stats" do
        Decidim.stats.register :assemblies_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Assembly.where(organization:).public_spaces.count
        end
      end

      initializer "decidim_assemblies.menu" do
        Decidim.menu :menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim"),
                        decidim_assemblies.assemblies_path,
                        position: 2.2,
                        if: OrganizationPublishedAssemblies.new(current_organization, current_user).any?,
                        active: :inclusive
        end
      end

      initializer "decidim_assemblies.view_hooks" do
        Decidim.view_hooks.register(:user_profile_bottom, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          assemblies = OrganizationPublishedAssemblies.new(view_context.current_organization, view_context.current_user)
                                                      .query.distinct
                                                      .joins(:members)
                                                      .merge(Decidim::AssemblyMember.where(user: view_context.profile_holder))
                                                      .reorder(title: :asc)

          next unless assemblies.any?

          # Since this is rendered inside a cell we need to access the parent context in order to render it.
          view_context = view_context.controller.view_context

          view_context.render(
            partial: "decidim/assemblies/pages/user_profile/member_of",
            locals: {
              assemblies:
            }
          )
        end
      end

      initializer "decidim_assemblies.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_assemblies) do |content_block|
          content_block.cell = "decidim/assemblies/content_blocks/highlighted_assemblies"
          content_block.public_name_key = "decidim.assemblies.content_blocks.highlighted_assemblies.name"
          content_block.settings_form_cell = "decidim/assemblies/content_blocks/highlighted_assemblies_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end
      end

      initializer "decidim_assemblies.register_metrics" do
        Decidim.metrics_registry.register(:assemblies) do |metric_registry|
          metric_registry.manager_class = "Decidim::Assemblies::Metrics::AssembliesMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home)
            settings.attribute :weight, type: :integer, default: 1
          end
        end
      end

      initializer "decidim_assemblies.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Assemblies::QueryExtensions
      end

      initializer "decidim_assemblies.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
