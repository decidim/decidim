# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe ImportProposalsToBudgets do
        describe "call" do
          let!(:proposals) { create_list(:proposal, 3, :accepted) }

          let!(:proposal) { proposals.first }
          let(:current_component) do
            create(
              :component, manifest_name: "budgets",
                          participatory_space: proposal.component.participatory_space
            )
          end
          let!(:current_user) { create(:user, :admin, organization: current_component.participatory_space.organization) }
          let!(:organization) { current_component.participatory_space.organization }
          let!(:import_form) do
            instance_double(
              ProjectImportProposalsForm,
              origin_component: proposal.component,
              current_component: current_component,
              default_budget: default_budget,
              import_all_accepted_proposals: import_all_accepted_proposals,
              valid?: valid
            )
          end

          let!(:project_forms) do
            rs = []

            proposals.each do |original_proposal|
              params = ActionController::Parameters.new(project: original_proposal.as_json)

              params[:project][:title] = project_localized(original_proposal.title)
              params[:project][:description] = project_localized(original_proposal.body)
              params[:project][:budget] = 10_000 # default_budget
              params[:project][:decidim_scope_id] = original_proposal.scope.id if original_proposal.scope
              params[:project][:decidim_component_id] = current_component.id
              params[:project][:decidim_category_id] = original_proposal.category.id if original_proposal.category
              params[:project][:proposal_ids] = original_proposal.id

              r = ProjectForm.from_params(params).with_context(
                current_user: current_user,
                current_organization: organization,
                current_participatory_space: current_component.participatory_space,
                current_component: current_component
              )

              rs << r
            end
            rs
          end

          let(:default_budget) { 1000 }
          let(:import_all_accepted_proposals) { true }

          let(:command) { described_class.new(import_form, project_forms) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create the project" do
              expect do
                command.call
              end.to change(Project, :count).by(0)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the projects" do
              expect do
                command.call
              end.to change { Project.where(component: current_component).count }.by(3)
            end

            context "when a proposal was already imported" do
              let(:second_proposal) { proposals.last }

              before do
                command.call
                second_proposal
              end

              it "doesn't import it again" do
                expect do
                  command.call
                end.to change { Project.where(component: current_component).count }.by(3)

                projects = Project.where(component: current_component)
                first_project = projects.first
                last_project = projects.last
                expect(translated(first_project.title)).to eq(proposal.title)
                expect(translated(last_project.title)).to eq(second_proposal.title)
              end
            end

            it "only imports wanted attributes" do
              command.call

              new_project = Project.where(component: current_component).last
              expect(translated(new_project.title)).to eq(proposals.last.title)
              expect(translated(new_project.description)).to eq(proposals.last.body)
              expect(new_project.category).to eq(proposals.last.category)
            end
          end
        end

        def project_localized(text)
          Decidim.available_locales.inject({}) do |result, locale|
            result.update(locale => text)
          end.with_indifferent_access
        end
      end
    end
  end
end
