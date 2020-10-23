# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
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
          resources :participatory_process_steps, only: [:index], path: "steps"
          resource :widget, only: :show, path: "embed"
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

      initializer "decidim_participatory_processes.query_extensions" do
        Decidim::Api::QueryType.define do
          QueryExtensions.define(self)
        end
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
                    active: %r{^/process(es|_groups)}
        end
      end

      initializer "decidim_participatory_processes.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_processes) do |content_block|
          content_block.cell = "decidim/participatory_processes/content_blocks/highlighted_processes"
          content_block.public_name_key = "decidim.participatory_processes.content_blocks.highlighted_processes.name"
          content_block.settings_form_cell = "decidim/participatory_processes/content_blocks/highlighted_processes_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :title) do |content_block|
          content_block.cell = "decidim/participatory_process_groups/content_blocks/title"
          content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.title.name"
          content_block.default!
        end

        (1..3).each do |index|
          Decidim.content_blocks.register(:participatory_process_group_homepage, :"html_#{index}") do |content_block|
            content_block.cell = "decidim/participatory_process_groups/content_blocks/html"
            content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.html_#{index}.name"
            content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

            content_block.settings do |settings|
              settings.attribute :html_content, type: :text, translated: true
            end
            content_block.default!
          end
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :metadata) do |content_block|
          content_block.cell = "decidim/participatory_process_groups/content_blocks/metadata"
          content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.metadata.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :cta) do |content_block|
          content_block.cell = "decidim/content_blocks/cta"
          content_block.settings_form_cell = "decidim/content_blocks/cta_settings_form"
          content_block.public_name_key = "decidim.content_blocks.cta.name"

          content_block.images = [
            {
              name: :background_image,
              uploader: "Decidim::HomepageImageUploader"
            }
          ]

          content_block.settings do |settings|
            settings.attribute :button_text, type: :text, translated: true
            settings.attribute :button_url, type: :string, required: true
            settings.attribute :description, type: :string, translated: true, editor: true
          end

          content_block.default!
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_proposals) do |content_block|
          content_block.cell = "decidim/proposals/content_blocks/highlighted_proposals"
          content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_settings_form"
          content_block.public_name_key = "decidim.proposals.content_blocks.highlighted_proposals.proposals"

          content_block.settings do |settings|
            settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
          end
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_results) do |content_block|
          content_block.cell = "decidim/accountability/content_blocks/highlighted_results"
          content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_settings_form"
          content_block.public_name_key = "decidim.accountability.content_blocks.highlighted_results.results"

          content_block.settings do |settings|
            settings.attribute :order, type: :enum, default: "random", choices: %w(random recent)
          end
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :highlighted_meetings) do |content_block|
          content_block.cell = "decidim/meetings/content_blocks/highlighted_meetings"
          content_block.public_name_key = "decidim.meetings.content_blocks.upcoming_events.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:participatory_process_group_homepage, :stats) do |content_block|
          content_block.cell = "decidim/participatory_process_groups/content_blocks/stats"
          content_block.public_name_key = "decidim.participatory_process_groups.content_blocks.stats.name"
          content_block.default!
        end
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
    end
  end
end
