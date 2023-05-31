# frozen_string_literal: true

module Decidim
  module Admin
    class SimpleMenuPresenter < Decidim::MenuPresenter
      def render(&)
        render_menu(&)
      end
    end
  end
end
