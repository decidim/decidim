# frozen_string_literal: true

require "budgets_workflow_random"
Decidim::Budgets.workflows[:random] = BudgetsWorkflowRandom
