# frozen_string_literal: true

module Decidim
  # A presenter to render menu items of breadcrumb root menu
  class BreadcrumbRootMenuItemPresenter < MenuItemPresenter
    include ::Webpacker::Helper
    include ::ActionView::Helpers::AssetUrlHelper
    include Decidim::LayoutHelper

    def render
      content_tag :li, class: link_wrapper_classes do
        output = [arrow_link(label, url, link_options)]
        output.push(@view.send(:simple_menu, **@menu_item.submenu).render) if @menu_item.submenu

        safe_join(output)
      end
    end

    def arrow_link(text, url, args = {})
      link_to url, class: args.with_indifferent_access[:class] do
        "<span>#{text}</span> #{icon("arrow-right-line")}".html_safe
      end
    end
  end
end
