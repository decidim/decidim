# frozen_string_literal: true

RSpec.shared_context "when managing metrics" do
  def generate_metric_registry(date = nil)
    metric = described_class.for(date, organization)
    metric.save
    Decidim::Metric.all.load
  end
end
