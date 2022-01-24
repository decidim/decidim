# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Conferences
    # Decidim's Conferences Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Conferences::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :conferences, param: :slug, except: [:show, :destroy] do
          resource :publish, controller: "conference_publications", only: [:create, :destroy]
          resources :copies, controller: "conference_copies", only: [:new, :create]
          resources :speakers, controller: "conference_speakers"
          resources :partners, controller: "partners", except: [:show]
          resources :media_links, controller: "media_links"
          resources :registration_types, controller: "registration_types" do
            resource :publish, controller: "registration_type_publications", only: [:create, :destroy]
            collection do
              get :conference_meetings
            end
          end
          resources :conference_invites, only: [:index, :new, :create]
          resources :conference_registrations, only: :index do
            member do
              post :confirm
            end
            collection do
              get :export
            end
          end
          resource :diploma, only: [:edit, :update] do
            member do
              post :send, to: "diplomas#send_diplomas"
            end
          end
          resources :user_roles, controller: "conference_user_roles" do
            member do
              post :resend_invitation, to: "conference_user_roles#resend_invitation"
            end
          end

          resources :attachment_collections, controller: "conference_attachment_collections"
          resources :attachments, controller: "conference_attachments"
        end

        scope "/conferences/:conference_slug" do
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
        end

        scope "/conferences/:conference_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_conference_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_conferences.admin_conferences_components_menu" do
        Decidim.menu :admin_conferences_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_conferences.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_conferences.edit_component_permissions_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end
      initializer "decidim_conferences.conferences_admin_registrations_menu" do
        Decidim.menu :conferences_admin_registrations_menu do |menu|
          menu.add_item :conference_registration_types,
                        I18n.t("registration_types", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_registration_types_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_registration_types_path(current_participatory_space)),
                        if: allowed_to?(:read, :registration_type, conference: current_participatory_space)

          menu.add_item :conference_conference_registrations,
                        I18n.t("user_registrations", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_conference_registrations_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_conference_registrations_path(current_participatory_space)),
                        if: allowed_to?(:read, :conference_registration, conference: current_participatory_space)

          menu.add_item :conference_conference_invites,
                        I18n.t("conference_invites", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_conference_invites_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_conference_invites_path(current_participatory_space)),
                        if: allowed_to?(:read, :conference_invite, conference: current_participatory_space)

          menu.add_item :edit_conference_diploma,
                        I18n.t("diploma", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.edit_conference_diploma_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.edit_conference_diploma_path(current_participatory_space)),
                        if: allowed_to?(:update, :conference, conference: current_participatory_space)
        end
      end
      initializer "decidim_conferences.conferences_admin_attachments_menu" do
        Decidim.menu :conferences_admin_attachments_menu do |menu|
          menu.add_item :conference_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, conference: current_participatory_space)

          menu.add_item :conference_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, conference: current_participatory_space)
        end
      end
      initializer "decidim_conferences.conferences_admin_menu" do
        Decidim.menu :conferences_admin_menu do |menu|
          menu.add_item :edit_conference,
                        I18n.t("info", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.edit_conference_path(current_participatory_space),
                        position: 1,
                        if: allowed_to?(:update, :conference, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.edit_conference_path(current_participatory_space))

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.components_path(current_participatory_space)),
                        if: allowed_to?(:read, :component, conference: current_participatory_space),
                        submenu: { target_menu: :admin_conferences_components_menu, options: { container_options: { id: "components-list" } } }

          menu.add_item :categories,
                        I18n.t("categories", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.categories_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.categories_path(current_participatory_space)),
                        if: allowed_to?(:read, :category, conference: current_participatory_space)

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.conferences_submenu"),
                        "#",
                        active: is_active_link?(decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_conferences.conference_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, conference: current_participatory_space) ||
                            allowed_to?(:read, :attachment, conference: current_participatory_space),
                        submenu: { target_menu: :conferences_admin_attachments_menu }

          menu.add_item :conference_media_links,
                        I18n.t("media_links", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_media_links_path(current_participatory_space),
                        if: allowed_to?(:read, :media_link, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_media_links_path(current_participatory_space))

          menu.add_item :conference_partners,
                        I18n.t("partners", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_partners_path(current_participatory_space),
                        if: allowed_to?(:read, :partner, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_partners_path(current_participatory_space))

          menu.add_item :conference_speakers,
                        I18n.t("conference_speakers", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_speakers_path(current_participatory_space),
                        if: allowed_to?(:read, :conference_speaker, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_speakers_path(current_participatory_space))

          menu.add_item :registrations,
                        I18n.t("registrations", scope: "decidim.admin.menu.conferences_submenu"),
                        "#",
                        active: false,
                        if: allowed_to?(:read, :conference_invite, conference: current_participatory_space) ||
                            allowed_to?(:read, :registration_type, conference: current_participatory_space) ||
                            allowed_to?(:read, :conference_registration, conference: current_participatory_space),
                        submenu: { target_menu: :conferences_admin_registrations_menu }

          menu.add_item :conference_user_roles,
                        I18n.t("conference_admins", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_user_roles_path(current_participatory_space),
                        if: allowed_to?(:read, :conference_user_role, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_user_roles_path(current_participatory_space))

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.moderations_path(current_participatory_space),
                        if: allowed_to?(:read, :moderation, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.moderations_path(current_participatory_space))
        end
      end

      initializer "decidim_conferences.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim.admin"),
                        decidim_admin_conferences.conferences_path,
                        icon_name: "microphone",
                        position: 2.8,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :conferences)
        end
      end
    end
  end
end
