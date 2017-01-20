# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcessSteps in a
  # public layout.
  class ParticipatoryProcessStepsController < ApplicationController
    helper_method :participatory_process, :current_participatory_process
    layout "layouts/decidim/participatory_process", only: [:index]

    def index
      authorize! :read, ParticipatoryProcess
    end

    private

    def current_participatory_process
      participatory_process
    end

    def participatory_process
      @participatory_process ||= ParticipatoryProcess.find(params[:participatory_process_id])
    end
  end
end
