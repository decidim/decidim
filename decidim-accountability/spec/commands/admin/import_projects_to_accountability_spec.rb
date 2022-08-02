# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ImportProjectsToAccountability do
    let(:user) { create :user, organization: }

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }

    let(:current_component) { create(:component, manifest_name: "accountability", participatory_space:, published_at: accountability_component_published_at) }
    let(:accountability_component_published_at) { nil }

    let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space:) }
    let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
    let!(:project) { create(:project, budget:, selected_at:) }
    let(:selected_at) { Time.current }
    let(:weight) { 0.3 }
    let(:external_id) { "external-id" }
    let(:progress) { 89 }

    let(:command) { described_class.new(form) }
    let(:proposal_component) do
      create(:component, manifest_name: "proposals", participatory_space:)
    end

    let(:project_component) do
      create(:component, manifest_name: "budgets", participatory_space:)
    end

    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:form) do
      double(
        valid?: valid,
        current_component:,
        origin_component: budget_component,
        origin_component_id: budget_component.id,
        import_all_selected_projects: true,
        current_user: user
      )
    end
    let(:valid) { true }

    describe "#call" do
      subject { command.call }

      describe "when the form is not valid" do
        let(:valid) { false }

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end

        it "does not create results" do
          expect { subject }.not_to change(Result, :count)
        end
      end

      describe "when the form is valid" do
        let(:valid) { true }

        before do
          allow(form).to receive(:project_already_copied?)
        end

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        context "when status is not set" do
          it "creates the Results" do
            expect do
              subject
            end.to change { Result.where(component: current_component).count }.by(1)
          end
        end

        context "when the status is set" do
          let!(:status) { create :status, component: current_component, key: "ongoing", name: { en: "Ongoing" } }

          it "creates the result properly" do
            expect do
              subject
            end.to change { Result.where(component: current_component).count }.by(1)
            expect(Result.where(component: current_component).first.status).to eq(status)
          end
        end

        context "when a project has already copied" do
          let!(:second_project) { create(:project, budget:, selected_at:) }

          before do
            subject
          end

          it "does not copy the project" do
            expect { subject }.not_to change(Result.where(component: current_component), :count)
          end
        end

        context "when the project is not selected" do
          before do
            project.selected_at = nil
            project.save
          end

          it "does not copy them as result" do
            expect { subject }.not_to change(Result.where(component: current_component), :count)
          end
        end

        context "when copying project with linked proposals" do
          before do
            project.link_resources(proposals, "included_proposals")
            subject
          end

          it "links proposals and the project" do
            result = Result.first
            expect(result.linked_resources(:proposals, "included_proposals")).to match_array(proposals)
          end
        end
      end
    end
  end
end
