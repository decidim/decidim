# frozen_string_literal: true

module Decidim
  module Conferences
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim"),
                        decidim_conferences.conferences_path,
                        position: 2.8,
                        if: Decidim::Conference.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      def self.register_mobile_menu!
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim"),
                        decidim_conferences.conferences_path,
                        position: 2.8,
                        if: Decidim::Conference.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      def self.register_home_content_block_menu!
        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim"),
                        decidim_conferences.conferences_path,
                        position: 50,
                        if: Decidim::Conference.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      def self.register_admin_conferences_components_menu!
        Decidim.menu :admin_conferences_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = decidim_escape_translated(component.name)
            caption += content_tag(:span, component.primary_stat, class: "component-counter") if component.primary_stat.present?

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_conferences.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_conferences.edit_component_permissions_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_conferences.component_share_tokens_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      def self.register_conferences_admin_registrations_menu!
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

      def self.register_conferences_admin_attachments_menu!
        Decidim.menu :conferences_admin_attachments_menu do |menu|
          menu.add_item :conference_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, conference: current_participatory_space),
                        icon_name: "attachment-line"

          menu.add_item :conference_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, conference: current_participatory_space),
                        icon_name: "folder-line"
        end
      end

      def self.register_conferences_admin_menu!
        Decidim.menu :conferences_admin_menu do |menu|
          menu.add_item :edit_conference,
                        I18n.t("info", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.edit_conference_path(current_participatory_space),
                        position: 1,
                        icon_name: "information-line",
                        if: allowed_to?(:update, :conference, conference: current_participatory_space)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.components_path(current_participatory_space),
                        icon_name: "tools-line",
                        if: allowed_to?(:read, :component, conference: current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.components_path(current_participatory_space),
                                                ["decidim/conferences/admin/components", %w(index new edit)]),
                        submenu: { target_menu: :admin_conferences_components_menu }

          menu.add_item :categories,
                        I18n.t("categories", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.categories_path(current_participatory_space),
                        icon_name: "price-tag-3-line",
                        if: allowed_to?(:read, :category, conference: current_participatory_space)

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_attachments_path(current_participatory_space),
                        icon_name: "attachment-2",
                        active: is_active_link?(decidim_admin_conferences.conference_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_conferences.conference_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, conference: current_participatory_space) ||
                            allowed_to?(:read, :attachment_collection, conference: current_participatory_space)

          menu.add_item :conference_media_links,
                        I18n.t("media_links", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_media_links_path(current_participatory_space),
                        icon_name: "film-line",
                        active: is_active_link?(decidim_admin_conferences.conference_media_links_path(current_participatory_space))

          menu.add_item :conference_partners,
                        I18n.t("partners", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_partners_path(current_participatory_space),
                        icon_name: "service-line",
                        if: allowed_to?(:read, :partner, conference: current_participatory_space)

          menu.add_item :conference_speakers,
                        I18n.t("conference_speakers", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_speakers_path(current_participatory_space),
                        icon_name: "user-voice-line",
                        if: allowed_to?(:read, :conference_speaker, conference: current_participatory_space)

          menu.add_item :registrations,
                        I18n.t("registrations", scope: "decidim.admin.menu.conferences_submenu"),
                        "#",
                        active: false,
                        icon_name: "group-line",
                        if: allowed_to?(:read, :conference_invite, conference: current_participatory_space) ||
                            allowed_to?(:read, :registration_type, conference: current_participatory_space) ||
                            allowed_to?(:read, :conference_registration, conference: current_participatory_space),
                        submenu: { target_menu: :conferences_admin_registrations_menu }

          menu.add_item :conference_user_roles,
                        I18n.t("conference_admins", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.conference_user_roles_path(current_participatory_space),
                        icon_name: "user-settings-line",
                        if: allowed_to?(:read, :conference_user_role, conference: current_participatory_space)

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.conferences_submenu"),
                        decidim_admin_conferences.moderations_path(current_participatory_space),
                        icon_name: "flag-line",
                        if: allowed_to?(:read, :moderation, conference: current_participatory_space)

          menu.add_item :conference_share_tokens,
                        I18n.t("menu.share_tokens", scope: "decidim.admin"),
                        decidim_admin_conferences.conference_share_tokens_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_conferences.conference_share_tokens_path(current_participatory_space)),
                        icon_name: "share-line",
                        if: allowed_to?(:read, :share_tokens, current_participatory_space:)
        end
      end

      def self.register_admin_menu_modules!
        Decidim.menu :admin_menu_modules do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim.admin"),
                        decidim_admin_conferences.conferences_path,
                        icon_name: "live-line",
                        position: 2.8,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :conferences)
        end
      end
    end
  end
end
