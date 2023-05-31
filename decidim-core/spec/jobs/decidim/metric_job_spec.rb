# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricJob do
  subject { described_class }

  let(:manager_class) { Decidim::Metrics::UsersMetricManage }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:day) { Time.zone.today.strftime("%Y/%m/%d") }

  describe "queue" do
    it "is queued to metrics" do
      expect(subject.queue_name).to eq "metrics"
    end
  end

  describe "perform" do
    let(:manager_object) { double :manager_object }

    it "executes manager actions" do
      allow(manager_class)
        .to receive(:new)
        .with(day, organization)
        .and_return(manager_object)

      allow(manager_object)
        .to receive(:valid?)
        .and_return(true)

      expect(manager_object)
        .to receive(:save)

      subject.perform_now(manager_class.name, organization.id, day)
    end
  end
end
