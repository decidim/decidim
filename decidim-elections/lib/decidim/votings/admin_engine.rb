# frozen_string_literal: true

module Decidim
  module Votings
    # Decidim's Votings Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings, param: :slug do
          member do
            put :publish
            put :unpublish
            get :available_polling_officers
            get :polling_officers_picker
          end

          resource :landing_page, only: [:edit, :update], controller: "votings_landing_page" do
            resources :content_blocks, only: [:edit, :update], controller: "votings_landing_page_content_blocks"
          end

          resources :polling_stations
          resources :polling_officers, only: [:new, :create, :destroy, :index]
          resources :monitoring_committee_members, only: [:new, :create, :destroy, :index]
          resources :monitoring_committee_polling_station_closures, only: [:index, :edit, :show] do
            post :validate, on: :member
          end
          resources :monitoring_committee_verify_elections, only: [:index]
          resources :monitoring_committee_election_results, only: [:index, :show, :update]
          resources :attachments, controller: "voting_attachments"
          resources :attachment_collections, controller: "voting_attachment_collections"
          resources :ballot_styles

          resource :census, only: [:show, :destroy, :create], controller: "/decidim/votings/census/admin/census" do
            member do
              get :status
              get :generate_access_codes
              get :export_access_codes
              get :download_access_codes_file
            end
          end
        end

        scope "/votings/:voting_slug" do
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
          end
        end

        scope "/votings/:voting_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_voting_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_votings.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim.votings.admin"),
                        decidim_admin_votings.votings_path,
                        icon_name: "comment-square",
                        position: 2.6,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :votings)
        end
      end

      initializer "decidim_votings.admin_votings_components_menu" do
        Decidim.menu :admin_votings_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)),
                          if: component.manifest.admin_engine # && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      initializer "decidim_votings.decidim_votings_attachments_menu" do
        Decidim.menu :decidim_votings_attachments_menu do |menu|
          menu.add_item :voting_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection)

          menu.add_item :voting_attachments,
                        I18n.t("attachment_files", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment)
        end
      end

      initializer "decidim_votings.decidim_votings_monitoring_committee_menu" do
        Decidim.menu :decidim_votings_monitoring_committee_menu do |menu|
          menu.add_item :voting_monitoring_committee_members,
                        I18n.t("monitoring_committee_members", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_members_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_members_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_members)
          menu.add_item :monitoring_committee_polling_station_closures,
                        I18n.t("monitoring_committee_polling_station_closures", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_polling_station_closures_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_polling_station_closures_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_polling_station_closures, voting: current_participatory_space)
          menu.add_item :monitoring_committee_verify_elections,
                        I18n.t("monitoring_committee_verify_elections", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_verify_elections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_verify_elections_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_verify_elections, voting: current_participatory_space)
          menu.add_item :monitoring_committee_election_results,
                        I18n.t("monitoring_committee_election_results", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_election_results_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_election_results_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_election_results, voting: current_participatory_space)
        end
      end

      initializer "decidim_votings.decidim_voting_menu" do
        Decidim.menu :admin_voting_menu do |menu|
          menu.add_item :edit_voting,
                        I18n.t("info", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.edit_voting_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.edit_voting_path(current_participatory_space)),
                        if: allowed_to?(:edit, :voting, voting: current_participatory_space)

          menu.add_item :edit_voting_landing_page,
                        I18n.t("landing_page", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.edit_voting_landing_page_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_landing_page_path(current_participatory_space)),
                        if: allowed_to?(:update, :landing_page)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.components_path(current_participatory_space)),
                        if: allowed_to?(:read, :components, voting: current_participatory_space),
                        submenu: { target_menu: :admin_votings_components_menu, options: { container_options: { id: "components-list" } } }

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.votings.admin.menu.votings_submenu"),
                        "#",
                        active: is_active_link?(decidim_admin_votings.voting_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_votings.voting_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection) || allowed_to?(:read, :attachment),
                        submenu: { target_menu: :decidim_votings_attachments_menu }

          menu.add_item :voting_polling_stations,
                        I18n.t("polling_stations", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_polling_stations_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_polling_stations_path(current_participatory_space)),
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :polling_stations)

          menu.add_item :voting_polling_officers,
                        I18n.t("polling_officers", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_polling_officers_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_polling_officers_path(current_participatory_space)),
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :polling_officers)

          menu.add_item :voting_monitoring_committee,
                        I18n.t("monitoring_committee", scope: "decidim.votings.admin.menu.votings_submenu"),
                        "#",
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_members_path(current_participatory_space)),
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :monitoring_committee_menu, voting: current_participatory_space),
                        submenu: { target_menu: :decidim_votings_monitoring_committee_menu }

          menu.add_item :voting_ballot_styles,
                        I18n.t("ballot_styles", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_ballot_styles_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_ballot_styles_path(current_participatory_space)),
                        if: allowed_to?(:read, :ballot_styles)
        end
      end
    end
  end
end
