# frozen_string_literal: true

require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcessSteps in a
  # public layout.
  class ParticipatoryProcessStepsController < ApplicationController
    helper_method :participatory_process, :current_participatory_process
    layout "layouts/decidim/participatory_process", only: [:index]
    include NeedsParticipatoryProcess

    helper Decidim::ParticipatoryProcessHelper

    def index
      authorize! :read, ParticipatoryProcess
    end
  end
end
