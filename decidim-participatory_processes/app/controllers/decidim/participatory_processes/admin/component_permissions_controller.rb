# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Component
      # permissions in the admin panel.
      #
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
