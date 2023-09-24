# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # a participatory process.
      class ExportsController < Decidim::Admin::ExportsController
        include VotingAdmin
      end
    end
  end
end
