# frozen_string_literal: true

module Decidim
  module Budgets
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper_method :current_workflow

      def current_workflow
        @current_workflow ||= Decidim::Budgets.workflows[workflow_name].new(current_component, current_user)
      end

      private

      def workflow_name
        @workflow_name ||= current_component.settings.workflow.to_sym
      end
    end
  end
end
