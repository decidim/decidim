# frozen_string_literal: true

require "spec_helper"

describe Decidim::FindAndUpdateDescendantsJob do
  subject { described_class }

  let!(:participatory_process) { create(:participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:post_component) { create(:post_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, :official, component: proposal_component) }
  let!(:post) { create(:post, component: post_component) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "perform" do
    it "calls method on resources" do
      expect(proposal.searchable_resources).not_to be_empty
      expect(post.searchable_resources).not_to be_empty

      # rubocop:disable Rails/SkipsModelValidations:
      participatory_process.update_column(:published_at, nil)
      # rubocop:enable Rails/SkipsModelValidations:

      expect {
        Decidim::FindAndUpdateDescendantsJob.perform_now(participatory_process)
      }.to have_enqueued_job(Decidim::UpdateSearchIndexesJob).exactly(:twice)
    end
  end
end
