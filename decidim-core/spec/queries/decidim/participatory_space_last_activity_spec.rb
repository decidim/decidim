# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatorySpaceLastActivity do
  subject { query.query }

  let(:query) { described_class.new(participatory_space) }
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }

  let(:commentable) { create(:dummy_resource, component:) }
  let(:comment) { create(:comment, commentable:) }
  let!(:proposal_component) { create(:proposal_component) }
  let!(:withdrawn_proposal) { create(:proposal, :withdrawn, component: proposal_component) }
  let!(:proposal) { create(:proposal, :published, component: proposal_component) }
  let!(:action_log) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: comment, organization:, participatory_space:)
  end
  let!(:action_log_for_withdrawn_proposal) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: withdrawn_proposal, organization:, participatory_space:)
  end
  let!(:action_log_for_proposal) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: proposal, organization:, participatory_space:)
  end
  let(:component) do
    create(:component, :published, participatory_space:)
  end
  let(:resource) do
    create(:dummy_resource, component:, published_at: Time.current)
  end
  let!(:other_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource:, organization:, participatory_space:)
  end
  let(:another_comment) { create(:comment) }
  let!(:another_action_log) do
    create(:action_log, created_at: 2.days.ago, action: "create", visibility: "public-only", resource: another_comment, organization:)
  end

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(
        Decidim::Comments::Comment
        Decidim::Proposals::Proposal
        Decidim::Dev::DummyResource
      )
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::Dev::DummyResource)
    )
  end

  describe "#query" do
    it "returns the activities" do
      expect(subject.count).to eq(3)
      expect(subject).not_to include(another_action_log)
      expect(subject).not_to include(action_log_for_withdrawn_proposal)
      expect(subject).to include(action_log_for_proposal)
      expect(subject).to include(action_log)
    end
  end
end
