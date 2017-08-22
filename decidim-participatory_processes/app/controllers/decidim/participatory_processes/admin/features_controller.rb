# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Features in the
      # admin panel.
      #
      class FeaturesController < Decidim::Admin::FeaturesController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
