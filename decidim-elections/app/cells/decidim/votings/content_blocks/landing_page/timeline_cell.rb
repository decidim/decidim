# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class TimelineCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingTimelineCell")
          end
        end
      end
    end
  end
end
