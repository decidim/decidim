# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ResultsBulkActionsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::Admin::ComponentTaxonomiesHelper

        def update_taxonomies
          enforce_permission_to :create, :bulk_update

          Admin::UpdateResultTaxonomies.call(result_params[:taxonomies], result_ids, current_organization) do
            on(:invalid_taxonomies) do
              flash[:alert] = I18n.t(
                "results.update_taxonomies.select_a_taxonomy",
                scope: "decidim.accountability.admin"
              )
            end

            on(:invalid_resources) do
              flash[:alert] = I18n.t(
                "results.update_taxonomies.select_a_result",
                scope: "decidim.accountability.admin"
              )
            end

            on(:update_resources_taxonomies) do |response|
              if response[:successful].any?
                flash[:notice] = t(
                  "results.update_taxonomies.success",
                  taxonomies: response[:taxonomies].map { |taxonomy| decidim_escape_translated(taxonomy.name) }.to_sentence,
                  results: response[:successful].map { |resource| decidim_escape_translated(resource.title) }.to_sentence,
                  scope: "decidim.accountability.admin"
                )
              end
              if response[:errored].any?
                flash[:alert] = t(
                  "results.update_taxonomies.invalid",
                  taxonomies: response[:taxonomies].map { |taxonomy| decidim_escape_translated(taxonomy.name) }.to_sentence,
                  results: response[:errored].map { |resource| decidim_escape_translated(resource.title) }.to_sentence,
                  scope: "decidim.accountability.admin"
                )
              end
            end
          end

          redirect_to results_path
        end

        def update_status
          enforce_permission_to :create, :bulk_update

          UpdateResultStatus.call(result_params[:decidim_accountability_status_id], result_ids, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.update_status.success", scope: "decidim.accountability.admin")
              redirect_to results_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("results.update_status.invalid", scope: "decidim.accountability.admin")
              redirect_to results_path
            end
          end
        end

        def update_dates
          enforce_permission_to :create, :bulk_update

          UpdateResultDates.call(result_params[:start_date], result_params[:end_date], result_ids, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.update_dates.success", scope: "decidim.accountability.admin")
              redirect_to results_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("results.update_dates.invalid", scope: "decidim.accountability.admin")
              redirect_to results_path
            end
          end
        end

        private

        def result_ids
          result_params[:result_ids].map { |ids| ids.split(",") }.flatten.map(&:to_i)
        end

        def result_params
          @result_params ||= params.require(:result_bulk_actions).permit(
            :decidim_accountability_status_id,
            :start_date,
            :end_date,
            result_ids: [],
            taxonomies: []
          )
        end
      end
    end
  end
end
