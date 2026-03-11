# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe CalculatorHelper do
    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization: current_component.organization) }
    let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization: current_component.organization) }

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
        parent: nil,
        progress: 50
      )
    end

    before do
      allow(helper).to receive(:current_component).and_return(current_component)
    end

    describe "#progress_calculator" do
      it "calculates the average progress for all results when no taxonomy_id is given" do
        expect(helper.progress_calculator(nil)).to eq(27.5)
      end

      it "calculates the average progress for a specific taxonomy (including children)" do
        expect(helper.progress_calculator(taxonomy.id)).to eq(20)
      end

      it "handles taxonomy with no results gracefully" do
        other_taxonomy = create(:taxonomy, organization: current_component.organization)
        expect(helper.progress_calculator(other_taxonomy.id)).to be_nil
      end
    end

    describe "#count_calculator" do
      it "counts all results when no taxonomy_id is given" do
        expect(helper.count_calculator(nil)).to eq(4)
      end

      it "counts results for a specific taxonomy (including children)" do
        expect(helper.count_calculator(taxonomy.id)).to eq(3)
      end

      it "handles taxonomy with no results" do
        other_taxonomy = create(:taxonomy, organization: current_component.organization)
        expect(helper.count_calculator(other_taxonomy.id)).to eq(0)
      end
    end
  end
end
