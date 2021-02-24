# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class ElectionsCell < Decidim::ViewModel
          def show
            content_tag(:div, "VotingElectionsCell")
          end
        end
      end
    end
  end
end
