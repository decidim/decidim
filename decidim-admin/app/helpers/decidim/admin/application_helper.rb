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
      include Decidim::Admin::LogRenderHelper
      include Decidim::Admin::UserRolesHelper
      include Decidim::Admin::ResourceScopeHelper

      def title
        current_organization.name
      end

      # Adds a link to the secondary navigation so admins can easily access the public page of the
      # element their working on.
      #
      # url - The String with the URL to link to.
      #
      # Returns a String with a link wrapped in a <li> element.
      def public_page_link(url)
        content_tag(:li) do
          link_to url, class: "button", style: "color: #fff", target: "_blank", rel: "noopener" do
            I18n.t("decidim.admin.view_public_page")
          end
        end
      end
    end
  end
end
