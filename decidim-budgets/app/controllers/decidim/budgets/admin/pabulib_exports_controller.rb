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
          response.content_type = "text/csv"
          response.headers["Content-Disposition"] = %(attachment; filename="#{filename}")
          response.headers["Cache-Control"] = "no-cache"
          response.headers["Last-Modified"] = Time.now.httpdate

          exporter = Pabulib::Exporter.new(@form)
          exporter.export(budget, response)
        ensure
          response.stream.close
        end

        private

        def pabulib_vote_type_options
          Pabulib::VOTE_TYPES.map do |type|
            [t(type, scope: "activemodel.attributes.pabulib_vote_types", type:), type]
          end
        end

        def pabulib_scoring_fn_options
          Pabulib::SCORING_FNS
        end
      end
    end
  end
end
