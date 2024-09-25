# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe ProjectsController do
        routes { Decidim::Budgets::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "PATCH update" do
          let(:component) { create(:budgets_component) }
          let(:project) { create(:project, component:) }
          let(:project_title) { project.title }
          let(:project_params) do
            {
              title: project_title,
              description: project.description,
              budget_amount: project.budget_amount,
              decidim_scope_id: project.scope&.id,
              decidim_category_id: project.category&.id,
              proposal_ids: project.linked_resources(:proposals, "included_proposals").pluck(:id),
              selected: project.selected?,
              photos: project.photos.map { |a| a.id.to_s }
            }
          end
          let(:params) do
            {
              id: project.id,
              budget_id: project.budget.id,
              project: project_params
            }
          end

          it "updates the project" do
            allow(controller).to receive(:budget_projects_path).and_return("/projects")

            patch(:update, params:)

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
          end

          context "when the existing project has attachments and there are other errors on the form" do
            include_context "with controller rendering the view" do
              let(:project_title) { { en: "" } }
              let(:project) { create(:project, :with_photos, component:) }

              controller(ProjectsController) do
                helper_method :proposals_picker_projects_path
                def proposals_picker_projects_path
                  "/"
                end
              end

              it "displays the editing form with errors" do
                patch(:update, params:)

                expect(flash[:alert]).not_to be_empty
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:edit)
                expect(response.body).to include("There was a problem updating this project")
              end
            end
          end
        end

        describe "PATCH soft_delete" do
          let(:component) { create(:budgets_component) }
          let!(:project) { create(:project, component:) }

          it "soft deletes the project" do
            expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(project, user).and_call_original

            patch :soft_delete, params: { budget_id: project.budget.id, id: project.id }

            expect(response).to redirect_to budget_projects_path(project.budget)
            expect(flash[:notice]).not_to be_empty
            expect(project.reload.deleted_at).not_to be_nil
          end
        end

        describe "PATCH restore" do
          let(:component) { create(:budgets_component) }
          let!(:project) { create(:project, component:, deleted_at: Time.current) }

          it "restores the project" do
            expect(Decidim::Commands::RestoreResource).to receive(:call).with(project, user).and_call_original

            patch :restore, params: { budget_id: project.budget.id, id: project.id }

            expect(response).to redirect_to manage_trash_budget_projects_path(project.budget)
            expect(flash[:notice]).not_to be_empty
            expect(project.reload.deleted_at).to be_nil
          end
        end

        describe "GET manage_trash" do
          let(:component) { create(:budgets_component) }
          let!(:deleted_project) { create(:project, component:, deleted_at: Time.current) }
          let!(:active_project) { create(:project, component:) }

          it "lists only deleted projects" do
            get :manage_trash, params: { budget_id: deleted_project.budget.id }

            expect(response).to have_http_status(:ok)
            expect(controller.view_context.deleted_projects).to include(deleted_project)
            expect(controller.view_context.deleted_projects).not_to include(active_project)
          end

          it "renders the deleted projects template" do
            get :manage_trash, params: { budget_id: deleted_project.budget.id }

            expect(response).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
