# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ImportProjectsToAccountability do
    # subject { described_class.new(form) }

    let(:user) { create :user, organization: organization }

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization: organization) }

    let(:current_component) { create(:component, manifest_name: "accountability", participatory_space: participatory_space, published_at: accountability_component_published_at) }
    let(:accountability_component_published_at) { nil }

    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_space }
    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create :status, component: accountability_component, key: "ongoing", name: { en: "Ongoing" } }

    let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space: participatory_space) }
    let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
    let!(:project) { create(:project, budget: budget, selected_at: selected_at) }
    let(:selected_at) { Time.current }
    let(:weight) { 0.3 }
    let(:external_id) { "external-id" }
    let(:progress) { 89 }

    let(:command) { described_class.new(form) }
    let(:proposal_component) do
      create(:component, manifest_name: "proposals", participatory_space: participatory_space)
    end

    let(:project_component) do
      create(:component, manifest_name: "budgets", participatory_space: participatory_space)
    end

    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:form) do
      # Decidim::Accountability::Admin::ResultImportProjectsForm.from_params(
      #   origin_component_id: budget_component.id,
      #   import_all_selected_projects: true
      # )

      double(
        # Admin::ResultImportProjectsForm,
        valid?: valid,
        current_component: current_component,
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

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "creates the Results" do
          expect do
            subject
          end.to change { Result.count }.by(1)
        end
      end
    end
  end
end
