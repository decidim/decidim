# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows importing things.
      # It is targeted for customizations for importing things that lives under
      # a voting space.
      class ImportsController < Decidim::Admin::ImportsController
        include VotingAdmin
      end
    end
  end
end
