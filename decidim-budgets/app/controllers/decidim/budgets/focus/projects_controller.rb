# frozen_string_literal: true

module Decidim
  module Budgets
    module Focus
      class ProjectsController < Decidim::Budgets::ProjectsController
        def index
          super
          @focus_mode = true

          render "decidim/budgets/projects/index"
        end

        def show
          super
          @focus_mode = true

          render "decidim/budgets/projects/show"
        end
      end
    end
  end
end
