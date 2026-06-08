# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows an admin to export projects from a budget to
      # Pabulib format as defined at: https://pabulib.org/format
      class PabulibExportsController < Admin::ApplicationController
        helper_method :pabulib_vote_type_options, :pabulib_scoring_fn_options

        # Initializes the show view.
        def show
          enforce_permission_to(:export, :component_data, component: current_component)
          @form = form(PabulibExportForm).from_params(
            description: "#{translated_attribute(current_organization.name)} - #{translated_attribute(current_component.name)} - #{translated_attribute(budget.title)}",
            unit: translated_attribute(budget.title),
            instance: budget.created_at.strftime("%Y"),
            min_length: 1,
            max_length: budget.projects.count,
            vote_type: "approval"
          )
        end

        # Handles the form submission.
        def create
          enforce_permission_to(:export, :component_data, component: current_component)

          if budget.orders.finished.none?
            flash.now[:alert] = I18n.t("pabulib_exports.create.no_votes", scope: "decidim.budgets.admin")
            show
            return render :show, status: :unprocessable_content
          end

          @form = form(PabulibExportForm).from_params(params)
          unless @form.valid?
            flash.now[:alert] = I18n.t("pabulib_exports.create.invalid", scope: "decidim.budgets.admin")
            show
            return render :show, status: :unprocessable_content
          end

          filename = "decidim-budget-#{budget.id}-results-#{Time.zone.now.strftime("%Y-%m-%d-%H%M%S")}.pb"
          response.content_type = "text/csv"
          response.headers["Content-Disposition"] = %(attachment; filename="#{filename}")
          response.headers["Cache-Control"] = "no-cache, no-store"
          response.headers["Last-Modified"] = Time.current.httpdate

          exporter = Pabulib::Exporter.new(@form)
          exporter.export(budget, response)
        ensure
          response.stream.close
        end

        private

        # Returns the pabulib vote type options for the select tag helper.
        #
        # @return [Array<Array<String>>]
        def pabulib_vote_type_options
          Pabulib::VOTE_TYPES.map do |type|
            [t(type, scope: "activemodel.attributes.pabulib_vote_types", type:), type]
          end
        end

        # Returns the pabulib scoring functions for the select tag helper.
        #
        # @return [Array<String>]
        def pabulib_scoring_fn_options
          Pabulib::SCORING_FNS
        end
      end
    end
  end
end
