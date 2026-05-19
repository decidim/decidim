# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      # Exports a single budget to the Pabulib format (.pb).
      class Exporter
        include Decidim::TranslatableAttributes

        def initialize(config)
          @config = config
        end

        def export(budget, io)
          votes_by_project =
            Decidim::Budgets::LineItem
            .joins(:order)
            .where(decidim_project_id: budget.projects.select(:id))
            .where.not(decidim_budgets_orders: { checked_out_at: nil })
            .group(:decidim_project_id)
            .count

          writer = Pabulib::Writer.new(io, create_metadata_for(budget))
          writer.write_metadata
          writer.write_projects(budget.projects.order(:id)) { |project| convert_project(project, votes_by_project) }
          writer.write_votes(budget.orders.finished.order(:checked_out_at)) { |order| convert_vote(order) }
        end

        private

        attr_reader :config

        def create_metadata_for(budget)
          Pabulib::Metadata.new(
            description: config.description,
            country: config.country,
            unit: config.unit,
            instance: config.instance,
            num_projects: budget.projects.count,
            num_votes: budget.orders.finished.count,
            budget: budget.total_budget,
            vote_type: config.vote_type,
            min_length: config.min_length.presence || 1,
            max_length: config.max_length.presence || budget.projects.count,
            min_sum_cost: config.min_sum_cost,
            max_sum_cost: config.max_sum_cost,
            scoring_fn: config.scoring_fn,
            min_points: config.min_points,
            max_points: config.max_points,
            min_sum_points: config.min_sum_points,
            max_sum_points: config.max_sum_points,
            default_score: config.default_score
          ).tap do |metadata|
            finished_orders = budget.orders.finished
            if finished_orders.any?
              metadata.date_begin = finished_orders.order(:created_at).first.created_at
              metadata.date_end = finished_orders.order(:created_at).last.created_at
            end
          end
        end

        def convert_project(project, votes_by_project)
          Pabulib::Project.new(
            project_id: project.id,
            name: translated_attribute(project.title),
            cost: project.budget_amount,
            votes: votes_by_project.fetch(project.id, 0),
            selected: project.selected? ? 1 : 0
          )
        end

        def convert_vote(order)
          # Note that the voter ID is anonymized on purpose according to the
          # order ID. The ID of the user could expose their identity e.g.
          # through the API.
          Pabulib::Vote.new(
            voter_id: order.id,
            vote: order.projects.order(:id).pluck(:id).join(",")
          )
        end
      end
    end
  end
end
