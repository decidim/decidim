# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultsCalculator do
    subject { described_class.new(current_feature, scope.id, category.id) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: current_feature.organization }
    let(:other_scope) { create :scope, organization: current_feature.organization }
    let(:category) { create :category, participatory_space: current_feature.participatory_space }
    let!(:result1) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: nil,
        progress: 40
      )
    end
    let!(:result2) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: nil,
        progress: 20
      )
    end
    let!(:result3) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: scope,
        parent: nil,
        progress: nil
      )
    end
    let!(:result4) do
      create(
        :result,
        feature: current_feature,
        category: category,
        scope: other_scope,
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
