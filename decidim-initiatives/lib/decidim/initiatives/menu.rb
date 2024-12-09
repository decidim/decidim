# frozen_string_literal: true

module Decidim
  module Initiatives
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim"),
                        decidim_initiatives.initiatives_path,
                        position: 2.4,
                        active: %r{^/(initiatives|create_initiative)},
                        if: Decidim::InitiativesType.joins(:scopes).where(organization: current_organization).any?
        end
      end

      def self.register_mobile_menu!
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim"),
                        decidim_initiatives.initiatives_path,
                        position: 2.4,
                        active: %r{^/(initiatives|create_initiative)},
                        if: !Decidim::InitiativesType.joins(:scopes).where(organization: current_organization).all.empty?
        end
      end

      def self.register_home_content_block_menu!
        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim"),
                        decidim_initiatives.initiatives_path,
                        position: 30,
                        active: :inclusive,
                        if: Decidim::InitiativesType.joins(:scopes).where(organization: current_organization).any?
        end
      end

      def self.register_admin_menu_modules!
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

      def self.register_admin_initiatives_components_menu!
        Decidim.menu :admin_initiatives_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = decidim_escape_translated(component.name)
            caption += content_tag(:span, component.primary_stat, class: "component-counter") if component.primary_stat.present?

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_initiatives.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_initiatives.edit_component_permissions_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_initiatives.component_share_tokens_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine # && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      def self.register_admin_initiative_menu!
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
                        if: current_participatory_space.promoting_committee_enabled? && allowed_to?(:manage_membership, :initiative,
                                                                                                    initiative: current_participatory_space)

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

          menu.add_item :initiatives_share_tokens,
                        I18n.t("menu.share_tokens", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiative_share_tokens_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_initiatives.initiative_share_tokens_path(current_participatory_space)),
                        icon_name: "share-line",
                        if: allowed_to?(:read, :share_tokens, current_participatory_space:)
        end
      end

      def self.register_admin_initiative_actions_menu!
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

      def self.register_admin_initiatives_menu!
        Decidim.menu :admin_initiatives_menu do |menu|
          menu.add_item :initiatives,
                        I18n.t("menu.initiatives", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiatives_path,
                        position: 1,
                        icon_name: "lightbulb-flash-line",
                        active: is_active_link?(decidim_admin_initiatives.initiatives_path),
                        if: allowed_to?(:index, :initiative)

          menu.add_item :initiatives_types,
                        I18n.t("menu.initiatives_types", scope: "decidim.admin"),
                        decidim_admin_initiatives.initiatives_types_path,
                        position: 2,
                        icon_name: "layout-masonry-line",
                        active: is_active_link?(decidim_admin_initiatives.initiatives_types_path),
                        if: allowed_to?(:manage, :initiative_type)

          menu.add_item :initiatives_settings,
                        I18n.t("menu.initiatives_settings", scope: "decidim.admin"),
                        decidim_admin_initiatives.edit_initiatives_setting_path(
                          Decidim::InitiativesSettings.find_or_create_by!(
                            organization: current_organization
                          )
                        ),
                        position: 3,
                        icon_name: "tools-line",
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
