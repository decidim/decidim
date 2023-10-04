# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing categories for participatory processes.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
        include Concerns::ParticipatoryProcessAdmin

        add_breadcrumb_item_from_menu :admin_participatory_process_menu
      end
    end
  end
end
