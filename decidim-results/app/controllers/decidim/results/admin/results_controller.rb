# frozen_string_literal: true
module Decidim
  module Results
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        helper_method :results

        def new
          @form = form(ResultForm).instance
        end

        def create
          @form = form(ResultForm).from_params(params)

          CreateResult.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("results.create.success", scope: "decidim.results.admin")
              redirect_to results_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.create.invalid", scope: "decidim.results.admin")
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
              flash[:notice] = I18n.t("results.update.success", scope: "decidim.results.admin")
              redirect_to results_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.update.invalid", scope: "decidim.results.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          result.destroy!

          flash[:notice] = I18n.t("results.destroy.success", scope: "decidim.results.admin")

          redirect_to results_path
        end

        private

        def results
          @results ||= Result.where(feature: current_feature)
        end

        def result
          @result ||= results.find(params[:id])
        end
      end
    end
  end
end
