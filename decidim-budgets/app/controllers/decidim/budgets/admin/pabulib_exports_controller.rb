# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to export projects from a budget to
      # Pabulib format as defined at: https://pabulib.org/format
      class PabulibExportsController < Admin::ApplicationController
        helper_method :pabulib_vote_type_options, :pabulib_scoring_fn_options

        def show
          @form = form(PabulibExportForm).from_params(
            description: "#{translated_attribute(current_organization.name)} - #{translated_attribute(current_component.name)} - #{translated_attribute(budget.title)}",
            unit: translated_attribute(budget.title),
            instance: budget.created_at.strftime("%Y"),
            min_length: 1,
            max_length: budget.projects.count,
            vote_type: "approval"
          )
        end

        def create
          @form = form(PabulibExportForm).from_params(params)
          unless @form.valid?
            flash.now[:alert] = I18n.t("pabulib_exports.create.invalid", scope: "decidim.budgets.admin")
            return render :new
          end

          filename = "decidim-budget-#{budget.id}-results-#{Time.zone.now.strftime("%Y-%m-%d-%H%M%S")}.pb"
          response.content_type = "text/plain"
          response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
          response.headers["Cache-Control"] = "no-cache"
          response.headers["Last-Modified"] = Time.now.httpdate

          write("META")
          write(key: "value")
          write(description: @form.description)
          write_attributes(:country, :unit, :instance)
          write(num_projects: budget.projects.count)
          write(num_votes: budget.orders.finished.count)
          write(budget: budget.total_budget)
          write(rule: "greedy") # no other rules defined at this point
          write(vote_type: @form.vote_type)

          write_attributes(:min_length, :max_length)
          write_type_attributes
          if budget.orders.any?
            write(date_begin: budget.orders.order(:created_at).first.created_at.strftime("%Y-%m-%d"))
            write(date_end: budget.orders.order(:created_at).last.created_at.strftime("%Y-%m-%d"))
          end

          write("PROJECTS")
          write("project_id;name;cost;votes;selected")
          budget.projects.each do |project|
            votes_amount = Decidim::Budgets::LineItem.joins(:order).where(project:).where.not(
              decidim_budgets_orders: { checked_out_at: nil }
            ).count
            write(
              [
                project.id,
                translated_attribute(project.title),
                project.budget_amount,
                votes_amount,
                project.selected? ? 1 : 0
              ].join(";")
            )
          end
          return if budget.orders.none?

          write("VOTES")
          write_votes
        ensure
          response.stream.close
        end

        private

        def write(str = nil, **kwargs)
          response.write "#{str}\n" if str.present?
          return unless kwargs.any?

          response.write "#{kwargs.map { |key, val| [key, val].join(";") }.join(";")}\n"
        end

        def write_type_attributes
          case @form.vote_type
          when "approval"
            write_attributes(:min_sum_cost, :max_sum_cost)
          when "ordinal"
            write_attributes(:scoring_fn)
          when "cumulative"
            write_attributes(:min_points, :max_points, :min_sum_points, :max_sum_points)
          when "scoring"
            write_attributes(:min_points, :max_points, :default_score)
          end
        end

        def write_attributes(*attrs)
          attrs.each { |key| write("#{key};#{@form.public_send(key)}") if @form.public_send(key).present? }
        end

        # Separated to its own method to allow customization with more specific
        # voter data.
        def write_votes
          write(voter_id: "vote")
          budget.orders.finished.each do |order|
            # Note that the voter ID is anonymized on purpose according to the
            # order ID. The ID of the user could expose their identity e.g.
            # through the API.
            write([order.id, order.projects.pluck(:id).join(",")].join(";"))
          end
        end

        def pabulib_vote_type_options
          %w(approval ordinal cumulative scoring).map do |type|
            [t(type, scope: "activemodel.attributes.pabulib_vote_types", type:), type]
          end
        end

        def pabulib_scoring_fn_options
          ["Borda"]
        end
      end
    end
  end
end
