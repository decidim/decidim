# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      autoload :Exporter, "decidim/budgets/pabulib/exporter"
      autoload :Writer, "decidim/budgets/pabulib/writer"

      # For the structs and constants below, see https://pabulib.org/format.
      VOTE_TYPES = %w(approval ordinal cumulative scoring).freeze
      RULES = %w(
        greedy
        greedy-no-skip
        greedy-threshold
        greedy-exclusive
        greedy-custom
        equalshares
        equalshares-comparison
        equalshares/add1
        equalshares/add1-comparison
        unknown
      ).freeze
      SCORING_FNS = %w(Borda).freeze
      Metadata = Struct.new(
        :description,
        :country,
        :unit,
        :district,
        :subunit,
        :instance,
        :num_projects,
        :num_votes,
        :budget,
        :vote_type,
        :rule,
        :date_begin,
        :date_end,
        :min_length,
        :max_length,
        :min_sum_cost,
        :max_sum_cost,
        :scoring_fn,
        :min_points,
        :max_points,
        :min_sum_points,
        :max_sum_points,
        :default_score
      )
      Project = Struct.new(:project_id, :cost, :votes, :name, :selected)
      Vote = Struct.new(:voter_id, :vote)
    end
  end
end
