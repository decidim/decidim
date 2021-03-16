# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class ElectionsCell < Decidim::ViewModel
          delegate :current_participatory_space, to: :controller
          helper_method :single_election

          def show
            if single?
              render :single
            else
              render :show
            end
          end

          private

          def published_election_component_ids
            @published_election_component_ids ||= Decidim::Component
                                                  .where(
                                                    participatory_space: current_participatory_space,
                                                    manifest_name: :elections
                                                  )
                                                  .published
                                                  .pluck(:id)
          end

          def elections
            @elections ||= Decidim::Elections::Election
                           .where(component: published_election_component_ids)
                           .published
          end

          def elections_count
            @elections_count ||= elections.count
          end

          def single?
            elections.one?
          end

          def single_election
            @single_election ||= elections.first
          end
        end
      end
    end
  end
end
