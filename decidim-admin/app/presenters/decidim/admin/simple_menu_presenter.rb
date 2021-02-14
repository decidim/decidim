# frozen_string_literal: true

module Decidim
  module Admin
    class SimpleMenuPresenter < Decidim::MenuPresenter

      def render(&block)
        render_menu(&block)
      end
    end
  end
end
