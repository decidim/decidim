# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultsCalculator do
    subject { described_class.new(current_component, scope.id, category.id) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: current_component.organization }
    let(:other_scope) { create :scope, organization: current_component.organization }
    let(:category) { create :category, participatory_space: current_component.participatory_space }
    let!(:result1) do
      create(
        :result,
        component: current_component,
        category:,
        scope:,
        parent: nil,
        progress: 40
      )
    end
    let!(:result2) do
      create(
        :result,
        component: current_component,
        category:,
        scope:,
        parent: nil,
        progress: 20
      )
    end
    let!(:result3) do
      create(
        :result,
        component: current_component,
        category:,
        scope:,
        parent: nil,
        progress: nil
      )
    end
    let!(:result4) do
      create(
        :result,
        component: current_component,
        category:,
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
