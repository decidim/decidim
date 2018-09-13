# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        helper_method :results, :parent_result, :parent_results, :statuses

        def new
          enforce_permission_to :create, :result

          @form = form(ResultForm).instance
          @form.parent_id = params[:parent_id]
        end

        def create
          enforce_permission_to :create, :result

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
          enforce_permission_to :update, :result, result: result

          @form = form(ResultForm).from_model(result)
        end

        def update
          enforce_permission_to :update, :result, result: result

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
          enforce_permission_to :destroy, :result, result: result

          DestroyResult.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.destroy.success", scope: "decidim.accountability.admin")

              redirect_to results_path(parent_id: result.parent_id)
            end
          end
        end

        def proposals
          respond_to do |format|
            format.html do
              render partial: "proposals"
            end
            format.json do
              query = Decidim.find_resource_manifest(:proposals)
                             .try(:resource_scope, current_component)&.order(title: :asc)
              term = params[:term]
              if term&.start_with?("#")
                term.delete!("#")
                query = query.where("CAST(id AS TEXT) LIKE ?", "#{term}%")
              else
                query = query.where("title ilike ?", "%#{params[:term]}%")
              end
              render json: query.all.collect { |p| [present(p).title, p.id] }
            end
          end
        end

        private

        def results
          parent_id = params[:parent_id].presence
          @results ||= Result.where(component: current_component, parent_id: parent_id).page(params[:page]).per(15)
        end

        def result
          @result ||= Result.where(component: current_component).find(params[:id])
        end

        def parent_result
          @parent_result ||= Result.find_by(component: current_component, id: params[:parent_id])
        end

        def parent_results
          @parent_results ||= Result.where(component: current_component, parent_id: nil)
        end

        def statuses
          @statuses ||= Status.where(component: current_component)
        end
      end
    end
  end
end
