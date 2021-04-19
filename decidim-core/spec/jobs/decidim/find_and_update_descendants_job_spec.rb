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

  describe "#perform" do
    shared_examples_for "doesn't update search indexes" do
      it "doesn't update search indexes" do
        expect do
          Decidim::FindAndUpdateDescendantsJob.perform_now(participatory_process)
        end.not_to have_enqueued_job(Decidim::UpdateSearchIndexesJob)
      end
    end

    it "calls method on resources" do
      expect(proposal.searchable_resources).not_to be_empty
      expect(post.searchable_resources).not_to be_empty

      # rubocop:disable Rails/SkipsModelValidations:
      participatory_process.update_column(:published_at, nil)
      # rubocop:enable Rails/SkipsModelValidations:

      expect do
        Decidim::FindAndUpdateDescendantsJob.perform_now(participatory_process)
      end.to have_enqueued_job(Decidim::UpdateSearchIndexesJob).exactly(:twice)
    end

    context "when participatory process has no descendants" do
      let(:proposal_component) { nil }
      let(:post_component) { nil }
      let(:proposal) { nil }
      let(:post) { nil }

      it_behaves_like "doesn't update search indexes"
    end

    context "when participatory process descendant doesn't respond to components" do
      before do
        allow(participatory_process).to receive(:respond_to?).with(:components).and_return(false)
        allow(participatory_process).to receive(:respond_to?).with(:comments).and_return(false)
      end

      it_behaves_like "doesn't update search indexes"
    end

    context "when participatory process descendants has no components" do
      before do
        allow(participatory_process.components).to receive(:empty?).and_return(true)
        allow(participatory_process).to receive(:respond_to?).with(:components).and_return(true)
        allow(participatory_process).to receive(:respond_to?).with(:comments).and_return(false)
      end

      it_behaves_like "doesn't update search indexes"
    end
  end
end
