# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Budgets
    module Admin
      describe ProjectsController do
        let(:current_user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:budgets_component) }
        let!(:project) { create(:project, component:) }
        let!(:additional_params) { { budget_id: project.budget.id } }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "PATCH update" do
          let(:project_title) { project.title }
          let(:project_params) do
            {
              title: project_title,
              description: project.description,
              budget_amount: project.budget_amount,
              decidim_scope_id: project.scope&.id,
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

        it_behaves_like "a soft-deletable resource",
                        resource_name: :project,
                        resource_path: :budget_projects_path,
                        trash_path: :manage_trash_budget_projects_path
      end
    end
  end
end
