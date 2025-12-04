# frozen_string_literal: true

require "spec_helper"

describe Decidim::RemoveSearchIndexesJob do
  subject { described_class }

  let!(:participatory_process) { create(:participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }

  let!(:resource1) { create(:proposal, :official, component: proposal_component) }
  let!(:resource2) { create(:proposal, component: proposal_component) }

  let!(:comment) { create(:comment, commentable: resource2) }
  let!(:nested) { create(:comment, commentable: comment) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "perform" do
    it "calls method on resources when component is unpublished" do
      expect(resource1.searchable_resources).not_to be_empty
      expect(resource2.searchable_resources).not_to be_empty
      expect(comment.searchable_resources).not_to be_empty
      expect(nested.searchable_resources).not_to be_empty

      perform_enqueued_jobs do
        Decidim::Admin::UnpublishComponent.call(proposal_component, Decidim::User.first)
      end

      expect(resource1.searchable_resources).to be_empty
      expect(resource2.searchable_resources).to be_empty
      expect(comment.reload.searchable_resources).to be_empty
      expect(nested.reload.searchable_resources).to be_empty
    end

    it "calls method on resources when participatory_process is unpublished" do
      expect(resource1.searchable_resources).not_to be_empty
      expect(resource2.searchable_resources).not_to be_empty
      expect(comment.searchable_resources).not_to be_empty
      expect(nested.searchable_resources).not_to be_empty

      perform_enqueued_jobs do
        participatory_process.unpublish!
      end

      expect(resource1.searchable_resources).to be_empty
      expect(resource2.searchable_resources).to be_empty
      expect(comment.reload.searchable_resources).to be_empty
      expect(nested.reload.searchable_resources).to be_empty
    end
  end
end
