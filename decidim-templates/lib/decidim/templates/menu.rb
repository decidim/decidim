# frozen_string_literal: true

module Decidim
  module Templates
    class Menu
      def self.register_admin_template_types_menu!
        Decidim.menu :admin_template_types_menu do |menu|
          menu.add_item :questionnaires,
                        I18n.t("template_types.questionnaires", scope: "decidim.templates"),
                        decidim_admin_templates.questionnaire_templates_path,
                        icon_name: "clipboard-line",
                        if: allowed_to?(:index, :templates),
                        active: (
                          is_active_link?(decidim_admin_templates.questionnaire_templates_path) ||
                            is_active_link?(decidim_admin_templates.root_path)
                        ) && !is_active_link?(decidim_admin_templates.block_user_templates_path) &&
                                !is_active_link?(decidim_admin_templates.proposal_answer_templates_path)

          menu.add_item :user_reports,
                        I18n.t("template_types.block_user", scope: "decidim.templates"),
                        decidim_admin_templates.block_user_templates_path,
                        icon_name: "user-forbid-line",
                        if: allowed_to?(:index, :templates),
                        active: is_active_link?(decidim_admin_templates.block_user_templates_path)

          menu.add_item :proposal_answers,
                        I18n.t("template_types.proposal_answer_templates", scope: "decidim.templates"),
                        decidim_admin_templates.proposal_answer_templates_path,
                        icon_name: "file-copy-line",
                        if: allowed_to?(:index, :templates),
                        active: is_active_link?(decidim_admin_templates.proposal_answer_templates_path)
        end
      end

      def self.register_admin_menu!
        Decidim.menu :admin_menu do |menu|
          menu.add_item :questionnaire_templates,
                        I18n.t("menu.templates", scope: "decidim.admin", default: "Templates"),
                        decidim_admin_templates.questionnaire_templates_path,
                        icon_name: "file-copy-line",
                        position: 12,
                        active: is_active_link?(decidim_admin_templates.root_path),
                        if: allowed_to?(:read, :templates)
        end
      end
    end
  end
end
