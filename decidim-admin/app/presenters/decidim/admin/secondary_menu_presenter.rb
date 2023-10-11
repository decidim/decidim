# frozen_string_literal: true

module Decidim
  module Admin
    class SecondaryMenuPresenter < Decidim::MenuPresenter
      def render(render_options = {}, &)
        output = []
        output.push render_title(render_options) if render_options.fetch(:title, false)
        output.push render_menu(&)
        safe_join(output)
      end

      protected

      def render_title(render_options)
        content_tag :div, class: "secondary-nav__title" do
          render_options.fetch(:title)
        end
      end
    end
  end
end
