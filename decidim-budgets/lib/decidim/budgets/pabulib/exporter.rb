# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      # Exports a single budget to the Pabulib format (.pb).
      class Exporter
        include Decidim::TranslatableAttributes

        # Initializes the exporter.
        #
        # @param config [Decidim::Budgets::Admin::PabulibExportForm] The form
        #   object used to configure the export
        def initialize(config)
          @config = config
        end

        # Performs the export for the given budget and writes the data to the
        # provided IO stream.
        #
        # @param budget [Decidim::Budgets::Budget] The budget to create the export for
        # @param io [IO] An IO stream to write the output to
        # @return [nil]
        def export(budget, io)
          votes_by_project =
            Decidim::Budgets::LineItem
            .joins(:order)
            .where(decidim_project_id: budget.projects.select(:id))
            .where.not(decidim_budgets_orders: { checked_out_at: nil })
            .group(:decidim_project_id)
            .count
          projects_by_vote =
            Decidim::Budgets::LineItem
            .joins(:order)
            .where(decidim_project_id: budget.projects.select(:id))
            .where.not(decidim_budgets_orders: { checked_out_at: nil })
            .group(:decidim_order_id)
            .pluck(
              :decidim_order_id,
              Arel.sql(%(array_agg("decidim_budgets_line_items"."decidim_project_id")))
            )
            .to_h

          writer = Pabulib::Writer.new(io, create_metadata_for(budget))
          writer.write_metadata
          writer.write_projects(budget.projects.order(:id)) { |project| convert_project(project, votes_by_project) }
          writer.write_votes(budget.orders.finished.order(:checked_out_at)) { |order| convert_vote(order, projects_by_vote) }

          nil
        end

        private

        attr_reader :config

        # Creates a pabulib metadata instance from the configuration form and
        # the given budget.
        #
        # @param budget [Decidim::Budgets::Budget] The budget for the metadata
        # @return [Decidim::Budgets::Pabulib::Metadata] The created pabulib
        #   metadata instance
        def create_metadata_for(budget)
          Pabulib::Metadata.new(
            description: config.description,
            country: config.country,
            unit: config.unit,
            subunit: config.subunit,
            district: config.district,
            instance: config.instance,
            num_projects: budget.projects.count,
            num_votes: budget.orders.finished.count,
            budget: budget.total_budget,
            vote_type: config.vote_type,
            rule: config.rule,
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
              metadata.date_begin = finished_orders.order(:checked_out_at).first.checked_out_at
              metadata.date_end = finished_orders.order(:checked_out_at).last.checked_out_at
            end
          end
        end

        # Converts a project model to a pabulib project instance.
        #
        # @param project [Decidim::Budgets::Project] The project to convert
        # @param votes_by_project [Hash{Integer => Integer}] A hash containing
        #   the project IDs for the project as keys and their amount of
        #   confirmed votes as the values
        # @return [Decidim::Budgets::Pabulib::Project] The created pabulib
        #   project instance
        def convert_project(project, votes_by_project)
          Pabulib::Project.new(
            project_id: project.id,
            name: translated_attribute(project.title),
            cost: project.budget_amount,
            votes: votes_by_project.fetch(project.id, 0),
            selected: project.selected? ? 1 : 0
          )
        end

        # Converts an order model to pabulib order instance.
        #
        # @param order [Decidim::Budgets::Order] The order to convert
        # @param projects_by_vote [Hash{Integer => Array<Integer>}] A hash
        #   containing the selected project IDs for each vote, with the order
        #   IDs as keys and array of selected project IDs as values
        # @return [Decidim::Budgets::Pabulib::Vote] The created pabulib
        #   vote instance
        def convert_vote(order, projects_by_vote)
          # Note that the voter ID is anonymized on purpose according to the
          # order ID. The ID of the user could expose their identity e.g.
          # through the API.
          Pabulib::Vote.new(
            voter_id: order.id,
            vote: projects_by_vote.fetch(order.id, []).sort.join(",")
          )
        end
      end
    end
  end
end
