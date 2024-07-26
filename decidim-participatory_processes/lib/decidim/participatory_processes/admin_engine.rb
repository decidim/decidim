# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "decidim/participatory_processes/menu"

module Decidim
  module ParticipatoryProcesses
    # Decidim's Processes Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcesses::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :participatory_process_groups do
          resource :landing_page, only: [:edit, :update], controller: "participatory_process_group_landing_page" do
            resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "participatory_process_group_landing_page_content_blocks"
          end
        end
        resources :participatory_process_types
        resources :participatory_processes, param: :slug, except: [:show, :destroy] do
          resource :publish, controller: "participatory_process_publications", only: [:create, :destroy]
          resources :copies, controller: "participatory_process_copies", only: [:new, :create]

          resources :steps, controller: "participatory_process_steps" do
            resource :activate, controller: "participatory_process_step_activations", only: [:create, :destroy]
            collection do
              post :ordering, to: "participatory_process_step_ordering#create"
            end
          end
          resources :user_roles, controller: "participatory_process_user_roles" do
            member do
              post :resend_invitation, to: "participatory_process_user_roles#resend_invitation"
            end
          end
          resources :attachment_collections, controller: "participatory_process_attachment_collections", except: [:show]
          resources :attachments, controller: "participatory_process_attachments", except: [:show]

          resource :export, controller: "participatory_process_exports", only: :create

          collection do
            resources :imports, controller: "participatory_process_imports", only: [:new, :create]
          end
          resource :landing_page, only: [:edit, :update], controller: "participatory_process_landing_page" do
            resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "participatory_process_landing_page_content_blocks"
          end
        end

        scope "/participatory_processes/:participatory_process_slug" do
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

          resources :participatory_process_share_tokens, except: [:show], path: "share_tokens"
        end

        scope "/participatory_processes/:participatory_process_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_participatory_process_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_participatory_processes_admin.menu" do
        Decidim::ParticipatoryProcesses::Menu.register_admin_menu_modules!
        Decidim::ParticipatoryProcesses::Menu.register_admin_participatory_processes_menu!
        Decidim::ParticipatoryProcesses::Menu.register_participatory_process_admin_attachments_menu!
        Decidim::ParticipatoryProcesses::Menu.register_admin_participatory_process_components_menu!
        Decidim::ParticipatoryProcesses::Menu.register_admin_participatory_process_menu!
        Decidim::ParticipatoryProcesses::Menu.register_admin_participatory_process_group_menu!
        Decidim::ParticipatoryProcesses::Menu.register_admin_participatory_processes_manage_menu!
      end
    end
  end
end
