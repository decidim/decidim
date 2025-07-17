# frozen_string_literal: true

require "spec_helper"

describe Decidim::RemoveSearchIndexesJob do
  subject { described_class }

  let!(:participatory_process) { create(:participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }

  let!(:resource1) { create(:proposal, :official, component: proposal_component) }
  let!(:resource2) { create(:proposal, component: proposal_component) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "perform" do
    it "calls method on resources when component is unpublished" do
      expect(resource1.searchable_resources).not_to be_empty
      expect(resource2.searchable_resources).not_to be_empty

      # rubocop:disable Rails/SkipsModelValidations:
      proposal_component.update_column(:published_at, nil)
      # rubocop:enable Rails/SkipsModelValidations:

      Decidim::RemoveSearchIndexesJob.perform_now([resource1, resource2])

      expect(resource1.searchable_resources).to be_empty
      expect(resource2.searchable_resources).to be_empty
    end

    it "calls method on resources when participatory_process is unpublished" do
      expect(resource1.searchable_resources).not_to be_empty
      expect(resource2.searchable_resources).not_to be_empty

      # rubocop:disable Rails/SkipsModelValidations:
      participatory_process.update_column(:published_at, nil)
      # rubocop:enable Rails/SkipsModelValidations:

      Decidim::RemoveSearchIndexesJob.perform_now([resource1, resource2])

      expect(resource1.searchable_resources).to be_empty
      expect(resource2.searchable_resources).to be_empty
    end
  end
end
