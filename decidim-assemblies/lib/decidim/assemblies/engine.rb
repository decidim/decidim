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

        get "/assemblies/:assembly_id/f/:feature_id", to: redirect { |params, _request|
          assembly = Decidim::Assembly.find(params[:assembly_id])
          assembly ? "/assemblies/#{assembly.slug}/f/#{params[:feature_id]}" : "/404"
        }, constraints: { assembly_id: /[0-9]+/ }

        resources :assemblies, only: [:index, :show], param: :slug, path: "assemblies" do
          resource :assembly_widget, only: :show, path: "embed"
        end

        scope "/assemblies/:assembly_slug/f/:feature_id" do
          Decidim.feature_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentFeature.new(manifest) do
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
            "Decidim::Assemblies::Abilities::AdminAbility"
          ]
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
    end
  end
end
