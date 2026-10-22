# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:open_data:export", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when there are no organizations" do
    it "does not enqueue any jobs" do
      expect(Decidim::OpenDataJob).not_to receive(:perform_later)
      task.execute
    end
  end

  context "when there are organizations" do
    let!(:organization1) { create(:organization) }
    let!(:organization2) { create(:organization) }

    let(:resource_names) do
      (
        Decidim.open_data_manifests.select(&:include_in_open_data).map(&:name) +
        Decidim.component_manifests.flat_map(&:export_manifests).select(&:include_in_open_data?).map(&:name) +
        Decidim.participatory_space_manifests.flat_map(&:export_manifests).select(&:include_in_open_data?).map(&:name)
      ).uniq
    end

    before { allow(Decidim::OpenDataJob).to receive(:perform_later) }

    it "enqueues the global ZIP export job for each organization" do
      task.execute

      expect(Decidim::OpenDataJob).to have_received(:perform_later).with(organization1)
      expect(Decidim::OpenDataJob).to have_received(:perform_later).with(organization2)
    end

    it "enqueues a per-resource export job for each resource manifest and each organization" do
      task.execute

      resource_names.each do |resource|
        expect(Decidim::OpenDataJob).to have_received(:perform_later).with(organization1, resource)
        expect(Decidim::OpenDataJob).to have_received(:perform_later).with(organization2, resource)
      end
    end

    it "enqueues the correct total number of jobs" do
      task.execute

      expected_count = (1 + resource_names.count) * 2
      expect(Decidim::OpenDataJob).to have_received(:perform_later).exactly(expected_count).times
    end
  end
end
