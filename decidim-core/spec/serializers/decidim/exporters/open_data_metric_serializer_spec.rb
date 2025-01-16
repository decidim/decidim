# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe OpenDataMetricSerializer do
    subject { described_class.new(resource) }

    let(:resource) { create(:metric) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the day" do
        expect(serialized).to include(day: resource.day)
      end

      it "includes the metric_type" do
        expect(serialized).to include(metric_type: resource.metric_type)
      end

      it "includes the cumulative" do
        expect(serialized).to include(cumulative: resource.cumulative)
      end

      it "includes the quantity" do
        expect(serialized).to include(quantity: resource.quantity)
      end
    end
  end
end
