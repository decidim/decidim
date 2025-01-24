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
          let(:scope) { nil }
          let!(:form) do
            instance_double(
              ProjectImportProposalsForm,
              origin_component: proposal.component,
              current_component:,
              current_user:,
              default_budget:,
              import_all_accepted_proposals:,
              scope_id: scope&.id,
              budget:,
              valid?: valid
            )
          end

          let(:default_budget) { 1000 }
          let(:import_all_accepted_proposals) { true }

          let(:command) { described_class.new(form) }

          shared_context "with scoped proposals" do
            let(:scope) { create(:scope, organization:) }
            let(:scoped_proposals) { proposals[0..1] }

            before do
              current_component.participatory_space.update!(scope: space_scope) if respond_to?(:space_scope)

              settings = current_component.settings
              settings.scope_id = component_scope.id if respond_to?(:component_scope)
              settings.scopes_enabled = true
              current_component.settings = settings
              current_component.save!

              scoped_proposals.each { |pr| pr.update!(decidim_scope_id: scope.id) }
            end
          end

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

            context "when a scope is defined" do
              include_context "with scoped proposals"

              it "only imports the proposals mapped to the defined scope" do
                expect { command.call }.to(change { Project.where(budget:).where(scope:).count }.by(scoped_proposals.count))
              end
            end

            context "when there are no proposals in the selected scope" do
              let(:scope) { create(:scope, organization:) }

              it "does not create any project" do
                expect do
                  command.call
                end.not_to(change { Project.where(budget:).where(scope:).count })
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
              expect(new_project.scope).to eq(proposal.scope)
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
          end
        end
      end
    end
  end
end
