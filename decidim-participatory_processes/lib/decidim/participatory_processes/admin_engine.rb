# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

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
            resources :content_blocks, only: [:edit, :update], controller: "participatory_process_group_landing_page_content_blocks"
          end
        end
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
          resources :attachment_collections, controller: "participatory_process_attachment_collections"
          resources :attachments, controller: "participatory_process_attachments"

          resource :export, controller: "participatory_process_exports", only: :create

          collection do
            resources :imports, controller: "participatory_process_imports", only: [:new, :create]
          end
        end

        scope "/participatory_processes/:participatory_process_slug" do
          resources :categories

          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
            resources :imports, only: [:new, :create]
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
              resource :participatory_space_private_users_csv_import, only: [:new, :create], path: "csv_import"
            end
          end
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

      initializer "decidim_participatory_processes.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_participatory_processes_manifest.js)
      end

      initializer "decidim_participatory_processes.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesMenuHelper if respond_to?(:helper)
        end
      end

      initializer "decidim_participatory_processes.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                    decidim_admin_participatory_processes.participatory_processes_path,
                    icon_name: "target",
                    position: 2,
                    active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path, :inclusive) ||
                            is_active_link?(decidim_admin_participatory_processes.participatory_process_groups_path, :inclusive),
                    if: allowed_to?(:enter, :space_area, space_name: :processes) || allowed_to?(:enter, :space_area, space_name: :process_groups)
        end
      end

      initializer "decidim_participatory_processes.admin_participatory_processes_menu" do
        Decidim.menu :admin_participatory_processes_menu do |menu|
          menu.item I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                    decidim_admin_participatory_processes.participatory_processes_path,
                    position: 1,
                    if: allowed_to?(:enter, :space_area, space_name: :processes),
                    active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path)

          menu.item I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
                    decidim_admin_participatory_processes.participatory_process_groups_path,
                    position: 2,
                    if: allowed_to?(:enter, :space_area, space_name: :process_groups),
                    active: is_active_link?(decidim_admin_participatory_processes.participatory_process_groups_path)
        end
      end
      initializer "decidim_participatory_processes.admin_process_group_menu" do
        Decidim.menu :admin_participatory_process_menu do |menu|
        end
      end

      initializer "decidim_participatory_processes.admin_process_group_menu" do
        Decidim.menu :admin_participatory_process_group_menu do |menu|
          menu.item I18n.t("info", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                    decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group),
                    position: 1,
                    if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                    active: is_active_link?(decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group))
          menu.item I18n.t("landing_page", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                    decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group),
                    position: 2,
                    if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                    active: is_active_link?(decidim_admin_participatory_processes.participatory_process_group_landing_page_path(participatory_process_group))
        end
      end
    end
  end
end
