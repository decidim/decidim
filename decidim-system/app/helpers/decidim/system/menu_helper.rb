# frozen_string_literal: true

module Decidim
  module System
    # This module includes helpers to manage menus in system layout
    module MenuHelper
      # Public: Returns the main menu presenter object
      def main_menu
        @main_menu ||= ::Decidim::MenuPresenter.new(:system_menu, self)
      end
    end
  end
end
