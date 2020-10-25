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
          let(:budget) { create :budget, component: current_component }
          let!(:current_user) { create(:user, :admin, organization: current_component.participatory_space.organization) }
          let!(:organization) { current_component.participatory_space.organization }
          let(:scope) { nil }
          let!(:form) do
            instance_double(
              ProjectImportProposalsForm,
              origin_component: proposal.component,
              current_component: current_component,
              current_user: current_user,
              default_budget: default_budget,
              import_all_accepted_proposals: import_all_accepted_proposals,
              scope_id: scope,
              budget: budget,
              valid?: valid
            )
          end

          let(:default_budget) { 1000 }
          let(:import_all_accepted_proposals) { true }

          let(:command) { described_class.new(form) }

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
              end.to change { Project.where(budget: budget).count }.by(1)
            end

            context "when there are no proposals in the selected scope" do
              let(:scope) { create :scope, organization: organization }

              it "doesn't create any project" do
                expect do
                  command.call
                end.not_to(change { Project.where(budget: budget).where(scope: scope).count })
              end
            end

            context "when a proposal was already imported" do
              let(:second_proposal) { create(:proposal, :accepted, component: proposal.component) }

              before do
                command.call
                second_proposal
              end

              it "doesn't import it again" do
                expect do
                  command.call
                end.to change { Project.where(budget: budget).count }.by(1)

                projects = Project.where(budget: budget)
                first_project = projects.first
                last_project = projects.last
                expect(first_project.title).to eq(proposal.title)
                expect(last_project.title).to eq(second_proposal.title)
              end
            end

            it "links the proposals" do
              command.call
              last_project = Project.where(budget: budget).last

              linked = last_project.linked_resources(:proposals, "included_proposals")

              expect(linked).to include(proposal)
            end

            it "only imports wanted attributes" do
              command.call

              new_project = Project.where(budget: budget).last
              expect(new_project.title).to eq(proposal.title)
              expect(new_project.description).to eq(proposal.body)
              expect(new_project.category).to eq(proposal.category)
              expect(new_project.scope).to eq(proposal.scope)
            end
          end
        end
      end
    end
  end
end
