# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/initiatives/current_locale"
require "decidim/initiatives/initiatives_filter_form_builder"
require "decidim/initiatives/initiative_slug"
require "decidim/initiatives/api"
require "decidim/initiatives/query_extensions"

module Decidim
  module Initiatives
    # Decidim"s Initiatives Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Initiatives

      routes do
        get "/initiative_types/search", to: "initiative_types#search", as: :initiative_types_search
        get "/initiative_type_scopes/search", to: "initiatives_type_scopes#search", as: :initiative_type_scopes_search
        get "/initiative_type_signature_types/search", to: "initiatives_type_signature_types#search", as: :initiative_type_signature_types_search

        resources :create_initiative

        get "initiatives/:initiative_id", to: redirect { |params, _request|
          initiative = Decidim::Initiative.find(params[:initiative_id])
          initiative ? "/initiatives/#{initiative.slug}" : "/404"
        }, constraints: { initiative_id: /[0-9]+/ }

        get "/initiatives/:initiative_id/f/:component_id", to: redirect { |params, _request|
          initiative = Decidim::Initiative.find(params[:initiative_id])
          initiative ? "/initiatives/#{initiative.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { initiative_id: /[0-9]+/ }

        resources :initiatives, param: :slug, only: [:index, :show], path: "initiatives" do
          resources :initiative_signatures

          member do
            get :authorization_sign_modal, to: "authorization_sign_modals#show"
          end

          resource :initiative_vote, only: [:create, :destroy]
          resource :widget, only: :show, path: "embed"
          resources :committee_requests, only: [:new], shallow: true do
            collection do
              get :spawn
            end
          end
          resources :versions, only: [:show, :index]
        end

        scope "/initiatives/:initiative_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_initiative_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_initiatives.assets" do |app|
        app.config.assets.precompile += %w(
          decidim_initiatives_manifest.js
          decidim_initiatives_manifest.css
        )
      end

      initializer "decidim_initiatives.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_initiatives) do |content_block|
          content_block.cell = "decidim/initiatives/content_blocks/highlighted_initiatives"
          content_block.public_name_key = "decidim.initiatives.content_blocks.highlighted_initiatives.name"
          content_block.settings_form_cell = "decidim/initiatives/content_blocks/highlighted_initiatives_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end
      end

      initializer "decidim_initiatives.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Initiatives::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Initiatives::Engine.root}/app/views") # for partials
      end

      initializer "decidim_initiatives.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.initiatives", scope: "decidim"),
                    decidim_initiatives.initiatives_path,
                    position: 2.6,
                    active: :inclusive
        end
      end

      initializer "decidim_initiatives.badges" do
        Decidim::Gamification.register_badge(:initiatives) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            if model.is_a?(User)
              Decidim::Initiative.where(
                author: model,
                user_group: nil
              ).published.count
            elsif model.is_a?(UserGroup)
              Decidim::Initiative.where(
                user_group: model
              ).published.count
            end
          }
        end
      end

      initializer "decidim_initiatives.query_extensions" do
        Decidim::Api::QueryType.define do
          QueryExtensions.define(self)
        end
      end
    end
  end
end
