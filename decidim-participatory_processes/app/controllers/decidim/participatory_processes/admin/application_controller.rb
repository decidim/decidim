# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # The main admin application controller for participatory processes
      class ApplicationController < Decidim::Admin::ApplicationController
        def current_participatory_space_manifest_name
          :participatory_processes
        end
      end
    end
  end
end
