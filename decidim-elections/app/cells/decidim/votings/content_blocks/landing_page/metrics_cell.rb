# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class MetricsCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingMetricsCell")
          end
        end
      end
    end
  end
end
