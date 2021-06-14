# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # The main admin application controller for the voting census
        class ApplicationController < Decidim::Votings::Admin::ApplicationController
          layout "decidim/admin/voting"
          include Decidim::Votings::Admin::VotingAdmin

          def decidim_votings_admin
            Decidim::Votings::AdminEngine.routes.url_helpers
          end
        end
      end
    end
  end
end
