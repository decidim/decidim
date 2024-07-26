# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "decidim/assemblies/menu"

module Decidim
  module Assemblies
    # Decidim's Assemblies Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Assemblies::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :assemblies_types

        resources :assemblies, param: :slug, except: [:show, :destroy] do
          resource :publish, controller: "assembly_publications", only: [:create, :destroy]
          resources :copies, controller: "assembly_copies", only: [:new, :create]
          resources :members, controller: "assembly_members"

          resources :user_roles, controller: "assembly_user_roles" do
            member do
              post :resend_invitation, to: "assembly_user_roles#resend_invitation"
            end
          end

          resources :attachment_collections, controller: "assembly_attachment_collections", except: [:show]
          resources :attachments, controller: "assembly_attachments", except: [:show]

          resource :export, controller: "assembly_exports", only: :create

          collection do
            resources :imports, controller: "assembly_imports", only: [:new, :create]
          end

          resource :landing_page, only: [:edit, :update], controller: "assembly_landing_page" do
            resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "assembly_landing_page_content_blocks"
          end
        end

        scope "/assemblies/:assembly_slug" do
          resources :categories, except: [:show]

          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :component_share_tokens, except: [:show], path: "share_tokens", as: "share_tokens"
            resources :exports, only: :create
            resources :imports, only: [:new, :create] do
              get :example, on: :collection
            end
            resources :reminders, only: [:new, :create]
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
            resources :reports, controller: "moderations/reports", only: [:index, :show]
          end

          resources :participatory_space_private_users, controller: "participatory_space_private_users" do
            member do
              post :resend_invitation, to: "participatory_space_private_users#resend_invitation"
            end
            collection do
              resource :participatory_space_private_users_csv_imports, only: [:new, :create], path: "csv_import" do
                delete :destroy_all
              end
            end
          end

          resources :assembly_share_tokens, except: [:show], path: "share_tokens"
        end

        scope "/assemblies/:assembly_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_assembly_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_assemblies_admin.action_controller" do |app|
        app.config.to_prepare do
          ActiveSupport.on_load :action_controller do
            helper Decidim::Assemblies::Admin::AssembliesAdminMenuHelper if respond_to?(:helper)
          end
        end
      end

      initializer "decidim_assemblies_admin.menu" do
        Decidim::Assemblies::Menu.register_admin_menu_modules!
        Decidim::Assemblies::Menu.register_admin_assemblies_attachments_menu!
        Decidim::Assemblies::Menu.register_admin_assemblies_components_menu!
        Decidim::Assemblies::Menu.register_admin_assembly_menu!
        Decidim::Assemblies::Menu.register_admin_assemblies_menu!
      end
    end
  end
end
