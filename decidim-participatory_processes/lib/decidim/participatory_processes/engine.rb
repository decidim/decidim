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
        resources :participatory_process_groups, only: :show, path: "processes_groups"
        resources :participatory_processes, only: [:index, :show], path: "processes" do
          resources :participatory_process_steps, only: [:index], path: "steps"
          resource :participatory_process_widget, only: :show, path: "embed"
        end

        scope "/processes/:participatory_process_id/f/:feature_id" do
          Decidim.feature_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentFeature.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_participatory_process_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_participatory_processes.assets" do |app|
        app.config.assets.precompile += %w(decidim_participatory_processes_manifest.js)
      end

      initializer "decidim_participatory_processes.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.processes", scope: "decidim"),
                    decidim_participatory_processes.participatory_processes_path,
                    position: 2,
                    active: :inclusive
        end
      end
    end
  end
end
