# frozen_string_literal: true

module Decidim
  module Assemblies
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim"),
                        decidim_assemblies.assemblies_path(locale: current_locale),
                        position: 2.2,
                        if: OrganizationPublishedAssemblies.new(current_organization, current_user).any?,
                        active: :inclusive
        end
      end

      def self.register_mobile_menu!
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim"),
                        decidim_assemblies.assemblies_path(locale: current_locale),
                        position: 2.2,
                        if: OrganizationPublishedAssemblies.new(current_organization, current_user).any?,
                        active: :inclusive
        end
      end

      def self.register_home_content_block_menu!
        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim"),
                        decidim_assemblies.assemblies_path(locale: current_locale),
                        position: 20,
                        if: OrganizationPublishedAssemblies.new(current_organization, current_user).any?,
                        active: :inclusive
        end
      end

      def self.register_admin_menu_modules!
        Decidim.menu :admin_menu_modules do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim.admin"),
                        decidim_admin_assemblies.assemblies_path,
                        icon_name: "government-line",
                        position: 2.2,
                        active: is_active_link?(decidim_admin_assemblies.assemblies_path),
                        if: allowed_to?(:enter, :space_area, space_name: :assemblies)
        end
      end

      def self.register_admin_assemblies_attachments_menu!
        Decidim.menu :assemblies_admin_attachments_menu do |menu|
          menu.add_item :assembly_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, assembly: current_participatory_space),
                        icon_name: "attachment-line"
          menu.add_item :assembly_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, assembly: current_participatory_space),
                        icon_name: "folder-line"
        end
      end

      def self.register_admin_assemblies_components_menu!
        Decidim.menu :admin_assemblies_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = decidim_escape_translated(component.name)
            caption += content_tag(:span, component.primary_stat, class: "component-counter") if component.primary_stat.present?

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_assemblies.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_assemblies.edit_component_permissions_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_assemblies.component_share_tokens_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      def self.register_admin_assembly_menu!
        Decidim.menu :admin_assembly_menu do |menu|
          menu.add_item :edit_assembly,
                        I18n.t("info", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.edit_assembly_path(current_participatory_space),
                        position: 1,
                        icon_name: "information-line",
                        if: allowed_to?(:update, :assembly, assembly: current_participatory_space)

          menu.add_item :edit_assembly_landing_page,
                        I18n.t("landing_page", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.edit_assembly_landing_page_path(current_participatory_space),
                        icon_name: "layout-masonry-line",
                        if: allowed_to?(:update, :assembly, assembly: current_participatory_space)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.components_path(current_participatory_space),
                        icon_name: "tools-line",
                        active: is_active_link?(decidim_admin_assemblies.components_path(current_participatory_space), ["decidim/assemblies/admin/components", %w(index new edit)]),
                        if: allowed_to?(:read, :component, assembly: current_participatory_space),
                        submenu: { target_menu: :admin_assemblies_components_menu }

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_attachments_path(current_participatory_space),
                        icon_name: "attachment-2",
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachments_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, assembly: current_participatory_space) ||
                            allowed_to?(:read, :attachment, assembly: current_participatory_space)

          menu.add_item :assembly_user_roles,
                        I18n.t("assembly_admins", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_user_roles_path(current_participatory_space),
                        icon_name: "user-settings-line",
                        if: allowed_to?(:read, :assembly_user_role, assembly: current_participatory_space)

          menu.add_item :participatory_space_private_users,
                        I18n.t("private_users", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.participatory_space_private_users_path(current_participatory_space),
                        icon_name: "spy-line",
                        if: allowed_to?(:read, :space_private_user, current_participatory_space:)

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.moderations_path(current_participatory_space),
                        icon_name: "flag-line",
                        if: allowed_to?(:read, :moderation, assembly: current_participatory_space)

          menu.add_item :assembly_share_tokens,
                        I18n.t("menu.share_tokens", scope: "decidim.admin"),
                        decidim_admin_assemblies.assembly_share_tokens_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_share_tokens_path(current_participatory_space)),
                        icon_name: "share-line",
                        if: allowed_to?(:read, :share_tokens, current_participatory_space:)
        end
      end

      def self.register_admin_assemblies_menu!
        Decidim.menu :admin_assemblies_menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim.admin"),
                        decidim_admin_assemblies.assemblies_path,
                        position: 1,
                        active: is_active_link?(decidim_admin_assemblies.assemblies_path),
                        icon_name: "government-line",
                        if: allowed_to?(:read, :assembly_list)

          menu.add_item :import_assembly,
                        I18n.t("actions.import_assembly", scope: "decidim.admin"),
                        decidim_admin_assemblies.new_import_path,
                        position: 2,
                        active: is_active_link?(decidim_admin_assemblies.new_import_path),
                        icon_name: "price-tag-3-line",
                        if: allowed_to?(:import, :assembly)
        end
      end
    end
  end
end
