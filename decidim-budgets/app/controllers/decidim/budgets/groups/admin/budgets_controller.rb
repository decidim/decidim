# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Admin
        # This controller allows an admin to manage the budgets included in the group.
        class BudgetsController < Decidim::Budgets::Admin::ApplicationController
          include Decidim::Admin::ParticipatorySpaceAdminContext
        end
      end
    end
  end
end
