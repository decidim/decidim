# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricManage do
  let(:organization) { create(:organization) }
  let(:date) { (Time.zone.today - 1.week) }
  let(:yesterday_date) { Time.zone.today - 1.day }

  context "when executing a metric management" do
    it "creates a MetricManageObject" do
      manager = described_class.for(nil)

      expect(manager).to be_valid
      expect(manager.start_date).to eq(yesterday_date.beginning_of_day)
      expect(manager.end_date).to eq(yesterday_date.end_of_day)
    end

    it "creates a MetricManageObject with a passing date parameter" do
      manager = described_class.for(date.strftime("%Y-%m-%d"))

      expect(manager).to be_valid
      expect(manager.start_date).to eq(date.beginning_of_day)
      expect(manager.end_date).to eq(date.end_of_day)
    end

    it "fails with and invalid date" do
      expect(described_class.for("123456789")).not_to be_valid
    end
  end
end
