# frozen_string_literal: true

module Decidim
  module Admin
    class SecondaryMenuPresenter < Decidim::MenuPresenter
      delegate :concat, :capture, to: :@view

      def render(&block)
        content_tag :div, class: "secondary-nav secondary-nav--subnav" do
          content_tag :ul do
            elements = block_given? ? [block.call(@view)] : []
            safe_join(elements + menu_items)
          end
        end
      end
    end
  end
end
