# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class PollingStationsCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingPollingStationsCell")
          end
        end
      end
    end
  end
end
