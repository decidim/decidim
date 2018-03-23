# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

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
          resource :assembly_widget, only: :show, path: "embed"
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

      initializer "decidim_assemblies.assets" do |app|
        app.config.assets.precompile += %w(decidim_assemblies_manifest.js)
      end

      initializer "decidim_assemblies.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += [
            "Decidim::Assemblies::Abilities::EveryoneAbility",
            "Decidim::Assemblies::Abilities::AssemblyAdminAbility",
            "Decidim::Assemblies::Abilities::AssemblyCollaboratorAbility",
            "Decidim::Assemblies::Abilities::AssemblyModeratorAbility",
            "Decidim::Assemblies::Abilities::AdminAbility"
          ]
        end
      end

      initializer "decidim.stats" do
        Decidim.stats.register :assemblies_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Assembly.where(organization: organization).public_spaces.count
        end
      end

      initializer "decidim_assemblies.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.assemblies", scope: "decidim"),
                    decidim_assemblies.assemblies_path,
                    position: 2.5,
                    if: Decidim::Assembly.where(organization: current_organization).published.any?,
                    active: :inclusive
        end
      end

      initializer "decidim_assemblies.view_hooks" do
        Decidim.view_hooks.register(:highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          highlighted_assemblies = OrganizationPrioritizedAssemblies.new(view_context.current_organization, view_context.current_user)

          next unless highlighted_assemblies.any?

          view_context.render(
            partial: "decidim/assemblies/pages/home/highlighted_assemblies",
            locals: {
              highlighted_assemblies: highlighted_assemblies
            }
          )
        end
      end
    end
  end
end
