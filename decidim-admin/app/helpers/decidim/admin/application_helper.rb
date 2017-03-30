# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      include Decidim::LocalizedLocalesHelper
      include Decidim::TranslationsHelper
      include Decidim::HumanizeBooleansHelper
      include Decidim::AriaSelectedLinkToHelper
      include Decidim::MetaTagsHelper
      include Decidim::MapHelper

      def title
        current_organization.name
      end

      def admin_menu_item_to(name, url, options={})
        content_tag :li, class: options[:active_class] || active_link_to_class(url, active: options[:active], class_active: "is-active") do
          active_link_to url, active: options[:active], class_active: "is-active" do
            icon(options[:icon_name] || name) + I18n.t("menu.#{name}", scope: "decidim.admin")
          end
        end
      end
    end
  end
end
