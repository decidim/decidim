# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcessSteps in a
    # public layout.
    class ParticipatoryProcessStepsController < Decidim::ApplicationController
      helper_method :participatory_process, :current_participatory_process
      layout "layouts/decidim/participatory_process", only: [:index]
      include NeedsParticipatoryProcess

      helper ParticipatoryProcessHelper
      helper Decidim::IconHelper

      def index
        authorize! :read, ParticipatoryProcess
      end
    end
  end
end
