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
          let!(:form) do
            instance_double(
              ProjectImportProposalsForm,
              origin_component: proposal.component,
              current_component: current_component,
              default_budget: default_budget,
              import_all_accepted_proposals: import_all_accepted_proposals,
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
              end.to change { Project.where(component: current_component).count }.by(1)
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
                end.to change { Project.where(component: current_component).count }.by(1)

                projects = Project.where(component: current_component)
                first_project = projects.first
                last_project = projects.last
                expect(translated(first_project.title)).to eq(proposal.title)
                expect(translated(last_project.title)).to eq(second_proposal.title)
              end
            end

            it "links the proposals" do
              command.call
              last_project = Project.where(component: current_component).last

              linked = last_project.linked_resources(:proposals, "included_proposals")

              expect(linked).to include(proposal)
            end

            it "only imports wanted attributes" do
              command.call

              new_project = Project.where(component: current_component).last
              expect(translated(new_project.title)).to eq(proposal.title)
              expect(translated(new_project.description)).to eq(proposal.body)
              expect(new_project.category).to eq(proposal.category)
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
