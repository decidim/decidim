# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class PublishResultsForm < Decidim::Elections::Admin::ActionForm
        def groups
          @groups ||= [nil, *election.questions].map { |question| groups_for(question) }
        end

        private

        def closurables
          @closurables ||= Decidim::Votings::PollingStationClosure.where(election:) +
                           Decidim::Elections::BulletinBoardClosure.where(election:)
        end

        def groups_for(question)
          groups = {}

          aggregate_results_for(question).each do |key, total|
            update_group(groups, key[1, 2].join("."), key, total)
          end

          {
            question:,
            results: groups.values
          }
        end

        def aggregate_results_for(question)
          Decidim::Elections::Result.where(closurable: closurables, question:)
                                    .group(:closurable_type, :result_type, :decidim_elections_answer_id)
                                    .sum(:value)
        end

        def update_group(groups, group_id, key, total)
          closurable_type, result_type, answer_id = key
          groups[group_id] ||= {
            result_type:,
            answer: all_answers[answer_id],
            value: 0,
            polling_station: 0,
            bulletin_board: 0
          }

          groups[group_id][closurable_type_key[closurable_type]] = total
          groups[group_id][:value] += total
        end

        def closurable_type_key
          @closurable_type_key ||= {
            "Decidim::Votings::PollingStationClosure" => :polling_station,
            "Decidim::Elections::BulletinBoardClosure" => :bulletin_board
          }.freeze
        end

        def all_answers
          @all_answers ||= Decidim::Elections::Answer.where(question: election.questions).index_by(&:id)
        end
      end
    end
  end
end
