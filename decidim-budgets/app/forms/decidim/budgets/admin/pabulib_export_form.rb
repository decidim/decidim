# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create a new pabulib export for projects
      # from Decidim's admin panel.
      class PabulibExportForm < Decidim::Form
        attribute :description, String
        attribute :country, String
        attribute :unit, String
        attribute :instance, String

        attribute :vote_type, String
        attribute :min_length, Integer
        attribute :max_length, Integer

        # approval
        attribute :min_sum_cost, Integer
        attribute :max_sum_cost, Integer

        # ordinal
        attribute :scoring_fn, String

        # cumulative, scoring
        attribute :min_points, Integer
        attribute :max_points, Integer

        # cumulative
        attribute :min_sum_points, Integer
        attribute :max_sum_points, Integer

        # scoring
        attribute :default_score, Integer
      end
    end
  end
end
