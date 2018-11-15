# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Metrics::BudgetFollowersMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:budgets_component) { create(:budget_component, :published, participatory_space: participatory_space, settings: { vote_threshold_percent: 0 }) }
  let(:project) { create(:project, component: budgets_component, created_at: day) }
  let!(:follows) { create_list(:follow, 5, followable: project, created_at: day) }

  context "when executing class" do
    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, budgets_component).calculate

      expect(result[:cumulative_users].count).to eq(5)
      expect(result[:quantity_users].count).to eq(5)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, budgets_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
