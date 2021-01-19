# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This module, when injected into a controller, ensures there's a
      # Voting available and deducts it from the context.
      module VotingContext
        def self.extended(base)
          base.class_eval do
            include VotingAdmin

            alias_method :current_voting, :current_participatory_space
          end
        end
      end
    end
  end
end
