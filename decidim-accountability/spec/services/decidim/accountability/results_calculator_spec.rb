# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultsCalculator do
    subject { described_class.new(current_feature, scope.id, category.id) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: current_feature.organization }
    let(:category) { create :category, participatory_space: current_feature.participatory_space }
    let!(:parent_result) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: nil
      )
    end
    let!(:child_result1) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: parent_result

      )
    end
    let!(:child_result2) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: parent_result
      )
    end

    describe "count" do
      it "counts the results" do
        expect(subject.count).to eq 1
      end
    end

    describe "progress" do
      it "calculates an average of the progress" do
        expect(subject.progress).to eq parent_result.progress
      end
    end
  end
end
