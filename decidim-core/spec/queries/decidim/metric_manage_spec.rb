# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricManage do
  let(:organization) { create(:organization) }
  let(:date) { (Time.zone.today - 1.week) }
  let(:yesterday_date) { Time.zone.today - 1.day }
  let(:future_date) { Time.zone.today + 1.week }

  context "when executing a metric management" do
    it "creates a MetricManageObject" do
      manager = described_class.for(nil)

      expect(manager).to be_valid
      expect(manager.start_time).to eq(yesterday_date.beginning_of_day)
      expect(manager.end_time).to eq(yesterday_date.end_of_day)
    end

    it "creates a MetricManageObject with a passing date parameter" do
      manager = described_class.for(date.strftime("%Y-%m-%d"))

      expect(manager).to be_valid
      expect(manager.start_time).to eq(date.beginning_of_day)
      expect(manager.end_time).to eq(date.end_of_day)
    end

    it "fails with an invalid date" do
      expect { described_class.for("123456789") }.to raise_error(ArgumentError)
    end

    it "fails with a future date" do
      expect { described_class.for(future_date.strftime("%Y-%m-%d")) }.to raise_error(ArgumentError)
    end
  end
end
