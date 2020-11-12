# frozen_string_literal: true

require "spec_helper"

describe Decidim::UpdateResourcesIndexJob do
  subject { described_class }

  let!(:participatory_process) { create(:participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:resource) { create(:proposal, :official, component: proposal_component) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "perform" do
    it "calls method on resources" do
      expect(resource.searchable_resources).not_to be_empty

      participatory_process.update_column(:published_at, nil)

      Decidim::UpdateResourcesIndexJob.perform_now(participatory_process)

      expect(resource.searchable_resources).to be_empty
    end
  end
end
