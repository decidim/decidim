# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

require "decidim/consultations/query_extensions"

module Decidim
  module Consultations
    # Decidim"s Consultations Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Consultations

      routes do
        get "/consultations/:consultation_id", to: redirect { |params, _request|
          consultation = Decidim::Consultation.find(params[:consultation_id])
          consultation ? "/consultations/#{consultation.slug}" : "/404"
        }, constraints: { consultation_id: /[0-9]+/ }

        get "/questions/:question_id", to: redirect { |params, _request|
          question = Decidim::Consultations::Question.find(params[:question_id])
          question ? "/questions/#{question.slug}" : "/404"
        }, constraints: { question_id: /[0-9]+/ }

        resources :consultations, only: [:index, :show], param: :slug, path: "consultations" do
          resource :consultation_widget, only: :show, path: "embed"

          resources :questions, only: [:show], param: :slug, path: "questions", shallow: true do
            member do
              get :authorization_vote_modal, to: "authorization_vote_modals#show"
            end
            resource :question_widget, only: :show, path: "embed"
            resource :question_votes, only: [:create, :destroy], path: "vote"
            resource :question_multiple_votes, only: [:create, :show], path: "multivote"
          end
        end

        get "/questions/:question_id/f/:component_id", to: redirect { |params, _request|
          consultation = Decidim::Consultations::Question.find(params[:question_id])
          consultation ? "/questions/#{question.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { question_id: /[0-9]+/ }

        scope "/questions/:question_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_question_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim.stats" do
        Decidim.stats.register :consultations_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Consultation.where(organization: organization).published.count
        end
      end

      initializer "decidim_consultations.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Consultations::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Consultations::Engine.root}/app/views") # for partials
      end

      initializer "decidim_consultations.menu" do
        Decidim.menu :menu do |menu|
          menu.add_item :consultations,
                        I18n.t("menu.consultations", scope: "decidim"),
                        decidim_consultations.consultations_path,
                        position: 2.65,
                        if: Decidim::Consultation.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      initializer "decidim_consultations.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_consultations) do |content_block|
          content_block.cell = "decidim/consultations/content_blocks/highlighted_consultations"
          content_block.public_name_key = "decidim.consultations.content_blocks.highlighted_consultations.name"
          content_block.settings_form_cell = "decidim/consultations/content_blocks/highlighted_consultations_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end
      end

      initializer "decidim_consultations.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Consultations::QueryExtensions
      end

      initializer "decidim_consultations.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_consultations.authorization_transfer" do
        Decidim::AuthorizationTransfer.subscribe do |authorization, target_user|
          # rubocop:disable Rails/SkipsModelValidations
          Decidim::Consultations::Vote.where(author: authorization.user).update_all(
            decidim_author_id: target_user.id
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
