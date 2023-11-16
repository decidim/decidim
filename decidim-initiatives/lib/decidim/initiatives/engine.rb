# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/initiatives/current_locale"
require "decidim/initiatives/initiative_slug"
require "decidim/initiatives/menu"
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

        resources :create_initiative do
          collection do
            get :select_initiative_type
            put :select_initiative_type, to: "create_initiative#store_initiative_type"
            get :fill_data
            put :fill_data, to: "create_initiative#store_data"
            get :promotal_committee
            get :finish
          end
        end

        get "initiatives/:initiative_id", to: redirect { |params, _request|
          initiative = Decidim::Initiative.find(params[:initiative_id])
          initiative ? "/initiatives/#{initiative.slug}" : "/404"
        }, constraints: { initiative_id: /[0-9]+/ }

        get "/initiatives/:initiative_id/f/:component_id", to: redirect { |params, _request|
          initiative = Decidim::Initiative.find(params[:initiative_id])
          initiative ? "/initiatives/#{initiative.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { initiative_id: /[0-9]+/ }

        resources :initiatives, param: :slug, only: [:index, :show, :edit, :update], path: "initiatives" do
          resources :signatures, controller: "initiative_signatures" do
            collection do
              get :fill_personal_data
              put :fill_personal_data, to: "initiative_signatures#store_personal_data"
              get :sms_phone_number
              put :sms_phone_number, to: "initiative_signatures#store_sms_phone_number"
              get :sms_code
              put :sms_code, to: "initiative_signatures#store_sms_code"
              get :finish
              put :finish, to: "initiative_signatures#store_finish"
            end
          end

          member do
            get :authorization_sign_modal, to: "authorization_sign_modals#show"
            get :authorization_create_modal, to: "authorization_create_modals#show"
            get :print, to: "initiatives#print", as: "print"
            get :send_to_technical_validation, to: "initiatives#send_to_technical_validation"
          end

          resource :initiative_vote, only: [:create, :destroy]
          resources :committee_requests, only: [:new] do
            collection do
              get :spawn
            end
            member do
              get :approve
              delete :revoke
            end
          end
          resources :versions, only: [:show]
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

      initializer "decidim_initiatives.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_initiatives) do |content_block|
          content_block.cell = "decidim/initiatives/content_blocks/highlighted_initiatives"
          content_block.public_name_key = "decidim.initiatives.content_blocks.highlighted_initiatives.name"
          content_block.settings_form_cell = "decidim/initiatives/content_blocks/highlighted_initiatives_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
            settings.attribute :order, type: :string, default: "default"
          end
        end
      end

      initializer "decidim_initiatives.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Initiatives::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Initiatives::Engine.root}/app/views") # for partials
      end

      initializer "decidim_initiatives.menu" do
        Decidim::Initiatives::Menu.register_menu!
        Decidim::Initiatives::Menu.register_home_content_block_menu!
      end

      initializer "decidim_initiatives.badges" do
        Decidim::Gamification.register_badge(:initiatives) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            case model
            when User
              Decidim::Initiative.where(
                author: model,
                user_group: nil
              ).published.count
            when UserGroup
              Decidim::Initiative.where(
                user_group: model
              ).published.count
            end
          }
        end
      end

      initializer "decidim_initiatives.query_extensions" do
        Decidim::Api::QueryType.include QueryExtensions
      end

      initializer "decidim_initiatives.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_initiatives.preview_mailer" do
        # Load in mailer previews for apps to use in development.
        # We need to make sure we call `Preview.all` before requiring our
        # previews, otherwise any previews the app attempts to add need to be
        # manually required.
        if Rails.env.development? || Rails.env.test?
          ActionMailer::Preview.all

          Dir[root.join("spec/mailers/previews/**/*_preview.rb")].each do |file|
            require_dependency file
          end
        end
      end

      initializer "decidim_initiatives.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:initiatives) do |transfer|
            transfer.move_records(Decidim::Initiative, :decidim_author_id)
            transfer.move_records(Decidim::InitiativesVote, :decidim_author_id)
          end
        end
      end
    end
  end
end
