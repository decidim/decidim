# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.processes", scope: "decidim"),
                        decidim_participatory_processes.participatory_processes_path,
                        position: 2,
                        if: Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?,
                        active: %r{^/process(es|_groups)}
        end
      end

      def self.register_mobile_menu!
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.processes", scope: "decidim"),
                        decidim_participatory_processes.participatory_processes_path,
                        position: 2,
                        if: Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?,
                        active: %r{^/process(es|_groups)}
        end
      end

      def self.register_home_content_block_menu!
        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.processes", scope: "decidim"),
                        decidim_participatory_processes.participatory_processes_path,
                        position: 10,
                        if: Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?,
                        active: %r{^/process(es|_groups)}
        end
      end

      def self.register_admin_menu_modules!
        Decidim.menu :admin_menu_modules do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_processes_path,
                        icon_name: "treasure-map-line",
                        position: 2,
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path, :inclusive) ||
                                is_active_link?(decidim_admin_participatory_processes.participatory_process_groups_path, :inclusive) ||
                                is_active_link?(decidim_admin_participatory_processes.participatory_process_types_path),
                        if: allowed_to?(:enter, :space_area, space_name: :processes) || allowed_to?(:enter, :space_area, space_name: :process_groups)
        end
      end

      def self.register_admin_participatory_processes_menu!
        Decidim.menu :admin_participatory_processes_menu do |menu|
          menu.add_item :participatory_processes,
                        I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_processes_path,
                        position: 1,
                        icon_name: "home-8-line",
                        if: allowed_to?(:enter, :space_area, space_name: :processes),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path)

          menu.add_item :participatory_process_groups,
                        I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_process_groups_path,
                        position: 2,
                        icon_name: "home-8-line",
                        if: allowed_to?(:enter, :space_area, space_name: :process_groups),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_groups_path)
        end
      end

      def self.register_participatory_process_admin_attachments_menu!
        Decidim.menu :participatory_process_admin_attachments_menu do |menu|
          menu.add_item :participatory_process_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment),
                        icon_name: "attachment-line"

          menu.add_item :participatory_process_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection),
                        icon_name: "folder-line"
        end
      end

      def self.register_admin_participatory_process_components_menu!
        Decidim.menu :admin_participatory_process_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = decidim_escape_translated(component.name)
            caption += content_tag(:span, component.primary_stat, class: "component-counter") if component.primary_stat.present?

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_participatory_processes.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_participatory_processes.edit_component_permissions_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_participatory_processes.component_share_tokens_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      def self.register_admin_participatory_process_menu!
        Decidim.menu :admin_participatory_process_menu do |menu|
          menu.add_item :edit_participatory_process,
                        I18n.t("info", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.edit_participatory_process_path(current_participatory_space)),
                        icon_name: "information-line",
                        if: allowed_to?(:update, :process, process: current_participatory_space)

          menu.add_item :edit_participatory_process_landing_page,
                        I18n.t("landing_page", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_landing_page_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_landing_page_path(current_participatory_space)),
                        icon_name: "layout-masonry-line",
                        if: allowed_to?(:update, :process, process: current_participatory_space)

          menu.add_item :participatory_process_steps,
                        I18n.t("steps", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_steps_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_steps_path(current_participatory_space)),
                        icon_name: "direction-line",
                        if: allowed_to?(:read, :process_step)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.components_path(current_participatory_space),
                                                ["decidim/participatory_processes/admin/components", %w(index new edit)]),
                        icon_name: "tools-line",
                        if: allowed_to?(:read, :component),
                        submenu: { target_menu: :admin_participatory_process_components_menu }

          menu.add_item :categories,
                        I18n.t("categories", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.categories_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.categories_path(current_participatory_space)),
                        icon_name: "price-tag-3-line",
                        if: allowed_to?(:read, :category)

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_participatory_processes.participatory_process_attachments_path(current_participatory_space)),
                        icon_name: "attachment-2",
                        if: allowed_to?(:read, :attachment_collection) || allowed_to?(:read, :attachment)

          menu.add_item :participatory_process_user_roles,
                        I18n.t("process_admins", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_process_user_roles_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_user_roles_path(current_participatory_space)),
                        icon_name: "user-settings-line",
                        if: allowed_to?(:read, :process_user_role)

          menu.add_item :participatory_space_private_users,
                        I18n.t("private_users", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.participatory_space_private_users_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_space_private_users_path(current_participatory_space)),
                        icon_name: "spy-line",
                        if: allowed_to?(:read, :space_private_user, current_participatory_space:)

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.moderations_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.moderations_path(current_participatory_space)),
                        icon_name: "flag-line",
                        if: allowed_to?(:read, :moderation, current_participatory_space:)

          menu.add_item :participatory_process_share_tokens,
                        I18n.t("menu.share_tokens", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_process_share_tokens_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_share_tokens_path(current_participatory_space)),
                        icon_name: "share-line",
                        if: allowed_to?(:read, :share_tokens, current_participatory_space:)
        end
      end

      def self.register_admin_participatory_process_group_menu!
        Decidim.menu :admin_participatory_process_group_menu do |menu|
          menu.add_item :edit_participatory_process_group,
                        I18n.t("info", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group),
                        position: 1,
                        icon_name: "information-line",
                        if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                        active: is_active_link?(decidim_admin_participatory_processes.edit_participatory_process_group_path(participatory_process_group))
          menu.add_item :edit_participatory_process_group_landing_page,
                        I18n.t("landing_page", scope: "decidim.admin.menu.participatory_process_groups_submenu"),
                        decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(participatory_process_group),
                        position: 2,
                        icon_name: "layout-masonry-line",
                        if: allowed_to?(:update, :process_group, process_group: participatory_process_group),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_group_landing_page_path(participatory_process_group))
        end
      end

      def self.register_admin_participatory_processes_manage_menu!
        Decidim.menu :admin_participatory_processes_manage_menu do |menu|
          menu.add_item :processes,
                        I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_processes_path,
                        position: 1,
                        icon_name: "treasure-map-line",
                        if: allowed_to?(:read, :process_list),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_processes_path)

          menu.add_item :import_process,
                        I18n.t("actions.import_process", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.new_import_path,
                        position: 2,
                        icon_name: "upload-line",
                        if: allowed_to?(:import, :process),
                        active: is_active_link?(decidim_admin_participatory_processes.new_import_path)

          menu.add_item :participatory_process_types,
                        I18n.t("menu.participatory_process_types", scope: "decidim.admin"),
                        decidim_admin_participatory_processes.participatory_process_types_path,
                        position: 3,
                        icon_name: "price-tag-3-line",
                        if: allowed_to?(:manage, :participatory_process_type),
                        active: is_active_link?(decidim_admin_participatory_processes.participatory_process_types_path)
        end
      end
    end
  end
end
