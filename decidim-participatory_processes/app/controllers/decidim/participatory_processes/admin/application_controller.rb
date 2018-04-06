# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # The main admin application controller for participatory processes
      class ApplicationController < Decidim::Admin::ApplicationController
        private

        def permission_class
          Decidim::ParticipatoryProcesses::Permissions
        end
      end
    end
  end
end
