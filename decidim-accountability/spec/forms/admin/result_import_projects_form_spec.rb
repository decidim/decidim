# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ResultImportProjectsForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space: participatory_process) }
    let(:import_all_selected) { false }

    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_process
      }
    end

    let(:attributes) do
      {
        origin_component_id: budget_component.id,
        import_all_selected_projects: import_all_selected
      }
    end

    describe "when origin component presents" do
      let(:import_all_selected) { true }

      context "when some projects present" do
        before do
          allow(subject).to receive(:to_be_added_projects).and_return(1)
        end

        it { is_expected.to be_valid }
      end

      context "when no projects present" do
        before do
          allow(subject).to receive(:to_be_added_projects).and_return(0)
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe "when import all is not selexted" do
      let(:import_all_selected) { false }

      it { is_expected.not_to be_valid }
    end

    describe "when origin component does not present" do
      let(:origin_component_id) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "#origin_components" do
      subject { described_class.from_model(current_component).with_context(context) }
      before do
        create_list(:component, 4, manifest_name: "budgets", participatory_space: participatory_process)
      end

      it "returns all of the components" do
        expect(subject.origin_components.ids).to match_array(Decidim::Component.where(manifest_name: "budgets").ids)
      end
    end

    describe "#origin_components_collection" do
      subject { described_class.from_model(current_component).with_context(context) }
      let!(:all_components) { create_list(:component, 4, manifest_name: "budgets", participatory_space: participatory_process) }

      it "returns the collection of components" do
        components_array = all_components.map do |component|
          [component.name[I18n.locale.to_s], component.id]
        end
        expect(subject.origin_components_collection).to match_array(components_array)
      end
    end

    describe "#selceted_projects_count" do
      subject { described_class.from_model(current_component).with_context(context) }
      let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
      let!(:selected_set) { create(:project, budget:, selected_at: Time.current) }
      let!(:unselected_set) { create_list(:project, 3, budget:, selected_at: nil) }

      it "return number of selected projects" do
        expect(subject.selceted_projects_count(budget_component)).to eq(1)
      end
    end

    describe "#project_already_copied?" do
      subject { described_class.from_model(current_component).with_context(context) }
      let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
      let!(:project) { create(:project, budget:, selected_at: Time.current) }
      let!(:result) { create(:result, component: current_component) }

      context "when the project has not copied yet" do
        it "returns true" do
          rlt = subject.project_already_copied?(project)
          expect(rlt).to be_falsy
        end
      end

      context "when the project has already copied" do
        before do
          result.link_resources([project], "included_projects")
        end

        it "returns true" do
          rlt = subject.project_already_copied?(project)
          expect(rlt).to be_truthy
        end
      end
    end
  end
end
