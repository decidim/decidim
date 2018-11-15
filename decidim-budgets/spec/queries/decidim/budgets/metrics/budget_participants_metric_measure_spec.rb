# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Metrics::BudgetParticipantsMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }

  # Vote a participatory budgeting project (Budgets)
  let(:budgets_component) { create(:budget_component, :published, participatory_space: participatory_space, settings: { vote_threshold_percent: 0 }) }
  let(:orders) { create_list(:order, 5, component: budgets_component, checked_out_at: day) }
  # TOTAL Participants for Budgets: 5
  let(:all) { orders }

  context "when executing class" do
    before { all }

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
