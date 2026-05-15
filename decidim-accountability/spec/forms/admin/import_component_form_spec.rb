# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ImportComponentForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space: participatory_process) }
    let(:proposal_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }

    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_process
      }
    end

    let(:attributes) do
      {
        origin_component_id: budget_component.id
      }
    end

    describe "when origin component presents" do
      context "when some projects present" do
        before do
          allow(subject).to receive(:filtered_items_count).and_return(1)
        end

        it { is_expected.to be_valid }
      end

      context "when no projects present" do
        before do
          allow(subject).to receive(:filtered_items_count).and_return(0)
        end

        it { is_expected.not_to be_valid }
      end
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

    describe "#project_already_copied?" do
      subject { described_class.from_model(current_component).with_context(context) }
      let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
      let!(:project) { create(:project, budget:, selected_at: Time.current) }
      let!(:result) { create(:result, component: current_component) }

      context "when the project has not copied yet" do
        it "returns false" do
          expect(subject.project_already_copied?(project)).to be(false)
        end
      end

      context "when the project has already copied" do
        before do
          result.link_resources([project], "included_projects")
        end

        it "returns true" do
          expect(subject.project_already_copied?(project)).to be(true)
        end
      end
    end

    describe "#proposal_already_copied?" do
      subject { described_class.from_model(current_component).with_context(context) }
      let(:proposal) { create(:proposal, component: proposal_component) }
      let!(:result) { create(:result, component: current_component) }

      context "when the proposal has not copied yet" do
        it "returns false" do
          expect(subject.proposal_already_copied?(proposal)).to be(false)
        end
      end

      context "when the proposal has already copied" do
        before do
          result.link_resources([proposal], "included_proposals")
        end

        it "returns true" do
          expect(subject.proposal_already_copied?(proposal)).to be(true)
        end
      end
    end
  end
end
