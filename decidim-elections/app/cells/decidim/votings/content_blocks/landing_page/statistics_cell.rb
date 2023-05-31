# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class StatisticsCell < Decidim::StatisticsCell
          def show
            content_tag(:div, super, class: "section")
          end

          private

          def stats
            @stats ||= begin
              voting = Decidim::Votings::Voting.find_by(id: model.scoped_resource_id)
              Decidim::Votings::VotingStatsPresenter.new(voting:).collection
            end
          end
        end
      end
    end
  end
end
