# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This controller allows the create or update a budget.
      class BudgetsController < Admin::ApplicationController
        helper_method :budgets, :budget, :finished_orders, :pending_orders,
                      :users_with_pending_orders, :users_with_finished_orders

        def new
          enforce_permission_to :create, :budget
          @form = form(BudgetForm).instance
        end

        def create
          enforce_permission_to :create, :budget
          @form = form(BudgetForm).from_params(params, current_component:)

          CreateBudget.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("budgets.create.success", scope: "decidim.budgets.admin")
              redirect_to budgets_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("budgets.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :budget, budget: budget
          @form = form(BudgetForm).from_model(budget)
        end

        def update
          enforce_permission_to :update, :budget, budget: budget
          @form = form(BudgetForm).from_params(params, current_component:)

          UpdateBudget.call(@form, budget) do
            on(:ok) do
              flash[:notice] = I18n.t("budgets.update.success", scope: "decidim.budgets.admin")
              redirect_to budgets_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("budgets.update.invalid", scope: "decidim.budgets.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :budget, budget: budget

          DestroyBudget.call(budget, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("budgets.destroy.success", scope: "decidim.budgets.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("budgets.destroy.invalid", scope: "decidim.budgets.admin")
            end
          end

          redirect_to budgets_path
        end

        private

        def budgets
          @budgets ||= Budget.where(component: current_component).order(weight: :asc)
        end

        def budget
          @budget ||= budgets.find_by(id: params[:id])
        end

        def orders
          @orders ||= Order.where(decidim_budgets_budget_id: budgets)
        end

        def pending_orders
          orders.pending
        end

        def finished_orders
          orders.finished
        end

        def users_with_pending_orders
          orders.pending.pluck(:decidim_user_id).uniq
        end

        def users_with_finished_orders
          orders.finished.pluck(:decidim_user_id).uniq
        end
      end
    end
  end
end
