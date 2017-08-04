# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Feature
      # permissions in the admin panel.
      #
      class FeaturePermissionsController < Decidim::Admin::FeaturePermissionsController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
