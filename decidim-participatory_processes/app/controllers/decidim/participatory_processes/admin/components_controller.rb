# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
