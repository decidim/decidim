# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe ImportProposalsToBudgets do
        describe "call" do
          let!(:proposals) { create_list(:proposal, 3, :accepted, taxonomies: [taxonomy], component: proposals_component) }
          let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
          let(:proposals_component) { create(:proposal_component) }

          let!(:proposal) { proposals.first }
          let(:current_component) do
            create(
              :component,
              manifest_name: "budgets",
              participatory_space: proposals_component.participatory_space
            )
          end
          let(:budget) { create(:budget, component: current_component) }
          let!(:current_user) { create(:user, :admin, organization: current_component.participatory_space.organization) }
          let!(:organization) { current_component.participatory_space.organization }
          let!(:form) do
            instance_double(
              ProjectImportProposalsForm,
              origin_component: proposal.component,
              current_component:,
              current_user:,
              default_budget:,
              states:,
              budget:,
              valid?: valid
            )
          end

          let(:default_budget) { 1000 }
          let(:states) { ["accepted"] }

          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the project" do
              expect do
                command.call
              end.not_to change(Project, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the projects" do
              expect { command.call }.to change { Project.where(budget:).count }.by(3)
            end

            context "when importing multiple states" do
              let!(:rejected_proposals) { create_list(:proposal, 2, :rejected, component: proposals_component) }
              let(:states) { %w(accepted rejected) }

              it "imports proposals from all selected states" do
                expect { command.call }.to change { Project.where(budget:).count }.by(5)
              end
            end

            context "when importing custom states" do
              let!(:custom_state) { create(:proposal_state, token: "custom_state", component: proposals_component) }
              let!(:custom_state_proposals) do
                create_list(:proposal, 2, :published, component: proposals_component).each do |proposal|
                  proposal.update!(proposal_state: custom_state)
                end
              end
              let(:states) { ["custom_state"] }

              it "imports proposals with custom states" do
                expect { command.call }.to change { Project.where(budget:).count }.by(2)
              end
            end

            context "when there are no states" do
              let(:internal_states) { [] }

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "imports all proposals" do
                expect { command.call }.to change { Project.where(budget:).count }.by(3)
              end
            end

            context "when a proposal was already imported" do
              let(:second_proposal) { create(:proposal, :accepted, component: proposal.component) }

              before do
                command.call
                second_proposal
              end

              it "does not import it again" do
                expect do
                  command.call
                end.to change { Project.where(budget:).count }.by(1)

                projects = Project.where(budget:)
                first_project = projects.first
                last_project = projects.last
                expect(first_project.title).to eq(proposal.title)
                expect(last_project.title).to eq(second_proposal.title)
              end

              context "and the current component was not published" do
                before { current_component.unpublish! }

                it "does not import it again" do
                  expect do
                    command.call
                  end.to change { Project.where(budget:).count }.by(1)

                  projects = Project.where(budget:)
                  first_project = projects.first
                  last_project = projects.last
                  expect(first_project.title).to eq(proposal.title)
                  expect(last_project.title).to eq(second_proposal.title)
                end
              end
            end

            context "when proposals were already imported to another budget within the same component" do
              let(:another_budget) { create(:budget, component: current_component) }
              let!(:mapped_projects) do
                proposals.map do |pr|
                  project = create(:project, title: pr.title, description: pr.body, budget: another_budget)
                  project.link_resources([pr], "included_proposals")
                  project
                end
              end

              it "does not import it again" do
                expect { command.call }.not_to(change { Project.where(budget:).count })
              end
            end

            it "links the proposals" do
              command.call
              last_project = Project.where(budget:).order(:id).first

              linked = last_project.linked_resources(:proposals, "included_proposals")

              expect(linked).to include(proposal)
            end

            it "only imports wanted attributes" do
              command.call

              new_project = Project.where(budget:).order(:id).first
              expect(new_project.title).to eq(proposal.title)
              expect(new_project.description).to eq(proposal.body)
              expect(new_project.taxonomies).to eq(proposal.taxonomies)
              expect(new_project.budget_amount).to eq(proposal.cost)
            end

            context "when the proposal does not have a cost" do
              let!(:proposals) { create_list(:proposal, 3, :accepted, cost: nil, component: proposals_component) }

              it "imports the default budget" do
                command.call

                new_project = Project.where(budget:).order(:id).first
                expect(new_project.budget_amount).to eq(default_budget)
              end
            end

            describe "proposal states" do
              let(:states) { %w(not_answered rejected) }
              let!(:rejected_proposal) { create(:proposal, :rejected, component: proposals_component) }
              let!(:random_proposal) { create(:proposal, component: proposals_component) }
              let!(:withdrawn_proposal) { create(:proposal, :withdrawn, component: proposals_component) }
              let!(:hidden_proposal) { create(:proposal, component: proposals_component) }
              let!(:moderation) { create(:moderation, reportable: hidden_proposal, hidden_at: 1.day.ago) }

              it "only imports proposals from the selected states" do
                expect do
                  command.call
                end.to change { Project.where(budget:).count }.by(2)

                expect(Project.where(budget:).map(&:title)).to include(random_proposal.title)
                expect(Project.where(budget:).map(&:title)).to include(rejected_proposal.title)
                expect(Project.where(budget:).map(&:title)).not_to include(proposal.title)
                expect(Project.where(budget:).map(&:title)).not_to include(withdrawn_proposal.title)
                expect(Project.where(budget:).map(&:title)).not_to include(hidden_proposal.title)
              end
            end
          end
        end
      end
    end
  end
end
