# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      autoload :Exporter, "decidim/budgets/pabulib/exporter"
      autoload :Writer, "decidim/budgets/pabulib/writer"

      VOTE_TYPES = %w(approval ordinal cumulative scoring).freeze
      SCORING_FNS = %w(Borda).freeze
      Metadata = Struct.new(
        :description,
        :country,
        :unit,
        :instance,
        :num_projects,
        :num_votes,
        :budget,
        :vote_type,
        :min_length,
        :max_length,
        :min_sum_cost,
        :max_sum_cost,
        :scoring_fn,
        :min_points,
        :max_points,
        :min_sum_points,
        :max_sum_points,
        :default_score,
        :date_begin,
        :date_end
      )
      Project = Struct.new(:project_id, :name, :cost, :votes, :selected)
      Vote = Struct.new(:voter_id, :vote)
    end
  end
end
