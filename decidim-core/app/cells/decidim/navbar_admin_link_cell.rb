# frozen_string_literal: true

module Decidim
  # This cell renders a link in the top navbar
  # so admins can easily manage data without having to look for it at the admin
  # panel when they are at a public page.
  # example use:
  #   <%= cell("decidim/navbar_admin_link", { link_url: link_url, link_options: link_options }) %>
  #
  class NavbarAdminLinkCell < Decidim::ViewModel
    def show
      render if link_url
    end

    private

    def link_url
      return if model[:link_url].blank?

      model[:link_url]
    end

    def link_icon_name
      return "pencil-line" if model[:link_options][:icon].blank?

      model[:link_options][:icon]
    end

    def link_name
      return t("layouts.decidim.edit_link.edit") if model[:link_options][:name].blank?

      model[:link_options][:name]
    end

    def icon_options
      options = model[:icon_options].presence || {}

      options.merge(role: "img", "aria-hidden": true)
    end
  end
end
