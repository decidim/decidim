# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:open_data:export", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when there are no organizations" do
    it "does not enqueue any jobs" do
      expect { task.execute }.not_to have_enqueued_job(Decidim::OpenDataJob)
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

    it "enqueues the global ZIP export job for each organization" do
      expect { task.execute }
        .to have_enqueued_job(Decidim::OpenDataJob).with(organization1)
        .and have_enqueued_job(Decidim::OpenDataJob).with(organization2)
    end

    it "enqueues a per-resource export job for each resource manifest and each organization" do
      enqueued_args = []
      allow(Decidim::OpenDataJob).to receive(:perform_later) { |*args| enqueued_args << args }

      task.execute

      resource_names.each do |resource|
        expect(enqueued_args).to include([organization1, resource], [organization2, resource])
      end
    end

    it "enqueues the correct total number of jobs" do
      expected_count = (1 + resource_names.count) * 2

      expect { task.execute }.to have_enqueued_job(Decidim::OpenDataJob).exactly(expected_count).times
    end
  end
end
