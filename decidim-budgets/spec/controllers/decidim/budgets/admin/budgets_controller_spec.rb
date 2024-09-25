# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe BudgetsController do
        routes { Decidim::Budgets::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:budgets_component) }
        let(:budget) { create(:budget, component:) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "PATCH soft_delete" do
          it "soft deletes the budget" do
            expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(budget, user).and_call_original

            patch :soft_delete, params: { id: budget.id }

            expect(response).to redirect_to budgets_path
            expect(flash[:notice]).not_to be_empty
            expect(budget.reload.deleted_at).not_to be_nil
          end
        end

        describe "PATCH restore" do
          let!(:deleted_budget) { create(:budget, component:, deleted_at: Time.current) }

          it "restores the budget" do
            expect(Decidim::Commands::RestoreResource).to receive(:call).with(deleted_budget, user).and_call_original

            patch :restore, params: { id: deleted_budget.id }

            expect(response).to redirect_to manage_trash_budgets_path
            expect(flash[:notice]).not_to be_empty
            expect(deleted_budget.reload.deleted_at).to be_nil
          end
        end

        describe "GET deleted" do
          let!(:deleted_budget) { create(:budget, component:, deleted_at: Time.current) }
          let!(:active_budget) { create(:budget, component:) }

          it "lists only deleted budgets" do
            get :manage_trash

            expect(response).to have_http_status(:ok)
            expect(controller.view_context.deleted_budgets).to include(deleted_budget)
            expect(controller.view_context.deleted_budgets).not_to include(active_budget)
          end

          it "renders the deleted budgets template" do
            get :manage_trash

            expect(response).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
