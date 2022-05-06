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

      initializer "decidim_participatory_processes.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.participatory_processes", scope: "decidim.admin"),
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
          menu.add_item :participatory_processes,
                        I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_processes_path,
                        position: 1,
                        if: allowed_to?(:enter, :space_area, space_name: :processes),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path)

          menu.add_item :participatory_process_groups,
                        I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_process_groups_path,
                        position: 2,
                        if: allowed_to?(:enter, :space_area, space_name: :process_groups),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_groups_path)

          menu.add_item :participatory_process_types,
                        I18n.t("menu.participatory_process_types", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_process_types_path,
                        position: 3,
                        if: allowed_to?(:manage, :participatory_process_type),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_types_path)
        end
      end

      initializer "decidim_participatory_processes.admin_process_attachments_menu" do
        Decidim.menu :admin_participatory_process_attachments_menu do |menu|
          menu.add_item :participatory_process_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection)

          menu.add_item :participatory_process_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment)
        end
      end

      initializer "decidim_participatory_processes.admin_process_components_menu" do
        Decidim.menu :admin_participatory_process_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_participatory_processes.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_participatory_processes.edit_component_permissions_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      initializer "decidim_participatory_processes.admin_process_group_menu" do
        Decidim.menu :admin_participatory_process_menu do |menu|
          menu.add_item :edit_participatory_process,
                        I18n.t("info", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.edit_participatory_process_path(current_participatory_space)),
                        if: allowed_to?(:update, :process, process: current_participatory_space)

          menu.add_item :participatory_process_steps,
                        I18n.t("steps", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_steps_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_steps_path(current_participatory_space)),
                        if: allowed_to?(:read, :process_step)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.components_path(current_participatory_space)),
                        if: allowed_to?(:read, :component),
                        submenu: { target_menu: :admin_participatory_process_components_menu, options: { container_options: { id: "components-list" } } }

          menu.add_item :categories,
                        I18n.t("categories", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.categories_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.categories_path(current_participatory_space)),
                        if: allowed_to?(:read, :category)

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        "#",
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection) || allowed_to?(:read, :attachment),
                        submenu: { target_menu: :admin_participatory_process_attachments_menu }

          menu.add_item :participatory_process_user_roles,
                        I18n.t("process_admins", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_user_roles_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_user_roles_path(current_participatory_space)),
                        if: allowed_to?(:read, :process_user_role)

          menu.add_item :participatory_space_private_users,
                        I18n.t("private_users", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_space_private_users_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_space_private_users_path(current_participatory_space)),
                        if: allowed_to?(:read, :space_private_user)

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.moderations_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.moderations_path(current_participatory_space)),
                        if: allowed_to?(:read, :moderation)
        end
      end

      initializer "decidim_participatory_processes.admin_process_group_menu" do
        Decidim.menu :admin_participatory_process_group_menu do |menu|
          menu.add_item :edit_participatory_process_group,
                        I18n.t("info", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group),
                        position: 1,
                        if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                        active: is_active_link?(decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group))
          menu.add_item :edit_participatory_process_group_landing_page,
                        I18n.t("landing_page", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group),
                        position: 2,
                        if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_group_landing_page_path(participatory_process_group))
        end
      end
    end
  end
end
