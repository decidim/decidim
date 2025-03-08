# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Budgets
    module Admin
      describe BudgetsController do
        let(:current_user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:budgets_component) }
        let(:budget) { create(:budget, component:) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        it_behaves_like "a soft-deletable resource",
                        resource_name: :budget,
                        resource_path: :budgets_path,
                        trash_path: :manage_trash_budgets_path
      end
    end
  end
end
