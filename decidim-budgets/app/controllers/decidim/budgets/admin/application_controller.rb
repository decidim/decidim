# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :budget, :projects, :project, :maps_enabled?

        def budget
          @budget ||= Budget.where(component: current_component).includes(:projects).find_by(id: params[:budget_id])
        end

        def projects
          return unless budget

          @projects ||= budget.projects
        end

        def project
          @project ||= projects.find(params[:id])
        end

        def maps_enabled?
          @maps_enabled ||= current_component.settings.geocoding_enabled?
        end
      end
    end
  end
end
