# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing the Voting's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        layout "decidim/admin/voting"

        include NeedsVoting
      end
    end
  end
end
