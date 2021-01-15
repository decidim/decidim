# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing the Voting Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
        include Concerns::VotingAdmin
      end
    end
  end
end
