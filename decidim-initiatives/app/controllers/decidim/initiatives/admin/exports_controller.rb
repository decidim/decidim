# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # a participatory process.
      class ExportsController < Decidim::Admin::ExportsController
        include InitiativeAdmin
      end
    end
  end
end
