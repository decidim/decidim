# frozen_string_literal: true

module Decidim
  module Budgets
    module Focus
      class ProjectsController < Decidim::Budgets::ProjectsController
        before_action :set_focus_mode

        def index
          super

          render "decidim/budgets/projects/index"
        end

        def show
          super

          render "decidim/budgets/projects/show"
        end

        protected

        def set_focus_mode
          @focus_mode = true
        end
      end
    end
  end
end
