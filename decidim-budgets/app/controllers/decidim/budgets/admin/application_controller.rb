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
        helper_method :projects, :project

        include NeedsPermission

        private

        def permission_class
          Decidim::Budgets::Permissions
        end

        def permission_scope
          :admin
        end

        def projects
          @projects ||= Project.where(component: current_component)
        end

        def project
          @project ||= projects.find(params[:id])
        end
      end
    end
  end
end
