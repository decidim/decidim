# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        helper_method :results, :parent_result, :parent_results, :statuses

        def new
          @form = form(ResultForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          @form = form(ResultForm).from_params(params)

          CreateResult.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("results.create.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(ResultForm).from_model(result)
        end

        def update
          @form = form(ResultForm).from_params(params)

          UpdateResult.call(@form, result) do
            on(:ok) do
              flash[:notice] = I18n.t("results.update.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          result.destroy!

          flash[:notice] = I18n.t("results.destroy.success", scope: "decidim.accountability.admin")

          redirect_to results_path(parent_id: result.parent_id)
        end

        private

        def results
          parent_id = params[:parent_id].presence
          @results ||= Result.where(feature: current_feature, parent_id: parent_id).page(params[:page]).per(15)
        end

        def result
          @result ||= Result.where(feature: current_feature).find(params[:id])
        end

        def parent_result
          @parent_result ||= Result.where(feature: current_feature, id: params[:parent_id]).first
        end

        def parent_results
          @parent_results ||= Result.where(feature: current_feature, parent_id: nil)
        end

        def statuses
          @statuses ||= Status.where(feature: current_feature)
        end
      end
    end
  end
end
