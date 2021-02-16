# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class HeaderCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingHeaderCell")
          end
        end
      end
    end
  end
end
