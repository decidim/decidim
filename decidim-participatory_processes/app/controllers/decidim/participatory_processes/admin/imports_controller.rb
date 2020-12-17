# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # a participatory process.
      class ImportsController < Decidim::Admin::ImportsController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
