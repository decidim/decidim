# frozen_string_literal: true

module Decidim
  # A presenter to render footer menu
  class FooterMenuPresenter < MenuPresenter
    def render
      content_tag(:nav, role: "navigation", "aria-label" => @options[:label]) do
        safe_join([content_tag(:h2, @options[:label], class: "h5 mb-4"), render_menu])
      end
    end
  end
end
