# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe ProjectsController, type: :controller do
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

            patch :update, params: params

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
                patch :update, params: params

                expect(flash[:alert]).not_to be_empty
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:edit)
                expect(response.body).to include("There was a problem updating this project")
              end
            end
          end
        end

        context "when proposal linking is not enabled" do
          let(:component) { create(:budgets_component) }

          before do
            allow(Decidim::Budgets).to receive(:enable_proposal_linking).and_return(false)
          end

          it "does not load the proposals admin picker concern" do
            expect(Decidim::Budgets::Admin::ProjectsController).not_to receive(:include).with(
              Decidim::Proposals::Admin::Picker
            )

            load "#{Decidim::Budgets::Engine.root}/app/controllers/decidim/budgets/admin/projects_controller.rb"
          end
        end
      end
    end
  end
end
