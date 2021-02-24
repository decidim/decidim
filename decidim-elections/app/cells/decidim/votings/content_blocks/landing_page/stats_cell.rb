# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class StatsCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingStatsCell")
          end
        end
      end
    end
  end
end
