# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Initiatives
    # Decidim's Assemblies Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Initiatives::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :initiatives_types, except: :show do
          resource :permissions, controller: "initiatives_types_permissions"
          resources :initiatives_type_scopes, except: [:index, :show]
        end

        resources :initiatives_settings, only: [:edit, :update], controller: "initiatives_settings"

        resources :initiatives, only: [:index, :edit, :update], param: :slug do
          member do
            get :send_to_technical_validation
            post :publish
            delete :unpublish
            delete :discard
            get :export_votes
            get :export_pdf_signatures
            post :accept
            delete :reject
          end

          collection do
            get :export
          end

          resources :attachments, controller: "initiative_attachments", except: [:show]

          resources :committee_requests, only: [:index] do
            member do
              get :approve
              delete :revoke
            end
          end

          resource :permissions, controller: "initiatives_permissions"

          resource :answer, only: [:edit, :update]
        end

        scope "/initiatives/:initiative_slug" do
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
            resources :reports, controller: "moderations/reports", only: [:index, :show]
          end
        end

        scope "/initiatives/:initiative_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_initiative_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_initiatives_admin.menu" do
        Decidim.menu :admin_menu_modules do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiatives_path,
                        icon_name: "lightbulb-flash-line",
                        position: 2.4,
                        active: is_active_link?(decidim_admin_initiatives.initiatives_path) ||
                                is_active_link?(decidim_admin_initiatives.initiatives_types_path) ||
                                is_active_link?(
                                  decidim_admin_initiatives.edit_initiatives_setting_path(
                                    Decidim::InitiativesSettings.find_or_create_by!(organization: current_organization)
                                  )
                                ),
                        if: allowed_to?(:enter, :space_area, space_name: :initiatives)
        end
      end

      initializer "decidim_initiatives_admin.components_menu" do
        Decidim.menu :admin_initiatives_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_initiatives.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_initiatives.edit_component_permissions_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine # && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      initializer "decidim_initiatives_admin.initiative_menu" do
        Decidim.menu :admin_initiative_menu do |menu|
          menu.add_item :edit_initiative,
                        I18n.t("menu.information", scope: "decidim.admin"),
                        decidim_admin_initiatives.edit_initiative_path(current_participatory_space),
                        icon_name: "information-line",
                        if: allowed_to?(:edit, :initiative, initiative: current_participatory_space)

          menu.add_item :initiative_committee_requests,
                        I18n.t("menu.committee_members", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiative_committee_requests_path(current_participatory_space),
                        icon_name: "group-line",
                        if: current_participatory_space.promoting_committee_enabled? && allowed_to?(:manage_membership, :initiative, initiative: current_participatory_space)

          menu.add_item :components,
                        I18n.t("menu.components", scope: "decidim.admin"),
                        decidim_admin_initiatives.components_path(current_participatory_space),
                        icon_name: "tools-line",
                        active: is_active_link?(decidim_admin_initiatives.components_path(current_participatory_space),
                                                ["decidim/initiatives/admin/components", %w(index new edit)]),
                        if: allowed_to?(:read, :component, initiative: current_participatory_space),
                        submenu: { target_menu: :admin_initiatives_components_menu }
          menu.add_item :initiative_attachments,
                        I18n.t("menu.attachments", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiative_attachments_path(current_participatory_space),
                        icon_name: "attachment-2",
                        if: allowed_to?(:read, :attachment, initiative: current_participatory_space)

          menu.add_item :moderations,
                        I18n.t("menu.moderations", scope: "decidim.admin"),
                        decidim_admin_initiatives.moderations_path(current_participatory_space),
                        icon_name: "flag-line",
                        if: allowed_to?(:read, :moderation)
        end
      end

      initializer "decidim_initiatives_admin.initiative_actions_menu" do
        Decidim.menu :admin_initiative_actions_menu do |menu|
          menu.add_item :answer_initiative,
                        I18n.t("actions.answer", scope: "decidim.initiatives"),
                        decidim_admin_initiatives.edit_initiative_answer_path(current_participatory_space),
                        if: allowed_to?(:answer, :initiative, initiative: current_participatory_space)

          menu.add_item :initiative_permissions,
                        I18n.t("actions.permissions", scope: "decidim.admin"),
                        decidim_admin_initiatives.edit_initiative_permissions_path(current_participatory_space, resource_name: :initiative),
                        if: current_participatory_space.allow_resource_permissions? && allowed_to?(:update, :initiative, initiative: current_participatory_space)
        end
      end

      initializer "decidim_initiatives_admin.initiatives_menu" do
        Decidim.menu :admin_initiatives_menu do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiatives_path,
                        position: 1.0,
                        active: is_active_link?(decidim_admin_initiatives.initiatives_path),
                        if: allowed_to?(:index, :initiative)

          menu.add_item :initiatives_types,
                        I18n.t("menu.initiatives_types", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiatives_types_path,
                        active: is_active_link?(decidim_admin_initiatives.initiatives_types_path),
                        if: allowed_to?(:manage, :initiative_type)

          menu.add_item :initiatives_settings,
                        I18n.t("menu.initiatives_settings", scope: "decidim.admin"),
                        decidim_admin_initiatives.edit_initiatives_setting_path(
                          Decidim::InitiativesSettings.find_or_create_by!(
                            organization: current_organization
                          )
                        ),
                        active: is_active_link?(
                          decidim_admin_initiatives.edit_initiatives_setting_path(
                            Decidim::InitiativesSettings.find_or_create_by!(organization: current_organization)
                          )
                        ),
                        if: allowed_to?(:update, :initiatives_settings)
        end
      end
    end
  end
end
