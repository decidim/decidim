# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # A controller that holds the logic to show ParticipatoryProcessSteps in a
  # public layout.
  class ParticipatoryProcessStepsController < ApplicationController
    layout "layouts/decidim/participatory_process", only: [:index]
    def index
      authorize! :read, ParticipatoryProcess
    end
  end
end
