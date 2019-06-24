# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows importing categories for participatory processes.
      #
      class CategoriesImportsController < Decidim::Admin::CategoriesImportsController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
