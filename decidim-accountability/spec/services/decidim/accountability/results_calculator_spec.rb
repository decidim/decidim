# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultsCalculator do
    subject { described_class.new(current_component, taxonomy.id) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization: current_component.organization) }
    let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization: current_component.organization) }
    let(:another_taxonomy) { create(:taxonomy, :with_parent, organization: current_component.organization) }
    let!(:result1) do
      create(
        :result,
        component: current_component,
        taxonomies: [taxonomy],
        parent: nil,
        progress: 40
      )
    end
    let!(:result2) do
      create(
        :result,
        component: current_component,
        taxonomies: [taxonomy, sub_taxonomy],
        parent: nil,
        progress: 20
      )
    end
    let!(:result3) do
      create(
        :result,
        component: current_component,
        taxonomies: [sub_taxonomy],
        parent: nil,
        progress: nil
      )
    end
    let!(:result4) do
      create(
        :result,
        component: current_component,
        taxonomies: [another_taxonomy],
        parent: nil,
        progress: 50
      )
    end

    describe "count" do
      it "counts the results" do
        expect(subject.count).to eq 3
      end
    end

    describe "progress" do
      it "calculates an average of the progress" do
        expect(subject.progress).to eq(20)
      end
    end
  end
end
