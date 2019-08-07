# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricManage do
  let(:organization) { create(:organization) }
  let(:date) { (Time.zone.today - 1.week) }
  let(:yesterday_date) { Time.zone.yesterday }
  let(:future_date) { Time.zone.today + 1.week }

  context "when executing a metric management" do
    it "creates a MetricManageObject" do
      manager = described_class.for(nil, organization)

      expect(manager).to be_valid
    end

    it "creates a MetricManageObject with a passing date parameter" do
      manager = described_class.new(date.strftime("%Y-%m-%d"), organization)

      expect(manager).to be_valid
    end

    it "fails with an invalid date" do
      expect { described_class.new("123456789", organization) }.to raise_error(ArgumentError)
    end

    it "fails with a future date" do
      expect { described_class.new(future_date.strftime("%Y-%m-%d"), organization) }.to raise_error(ArgumentError)
    end
  end
end
