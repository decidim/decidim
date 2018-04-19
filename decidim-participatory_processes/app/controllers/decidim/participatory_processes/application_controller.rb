# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ParticipatoryProcesses::ApplicationHelper

      def current_participatory_space_manifest_name
        :participatory_processes
      end
    end
  end
end
