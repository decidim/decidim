# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalAnswerJob do
  subject { described_class }

  let(:component) { create(:proposal_component, :with_creation_enabled) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:old_status) { create(:proposal_status, component:, token: "old_status") }
  let(:proposal) { create(:proposal, component:, proposal_status: old_status) }
  let(:new_status) do
    create(
      :proposal_status,
      title: { en: "Custom status" },
      token: "custom_status",
      component:
    )
  end

  let(:attributes) do
    {
      "answer" => { "en" => "Test answer" },
      "internal_status" => new_status.token
    }
  end

  let(:context) do
    {
      current_organization: organization,
      current_component: component,
      current_user: user
    }
  end

  describe "#perform" do
    before do
      # The n+1 query that we are ignoring here is coming from a background job, and we cannot really optimize it
      %w(amended amendable component coauthorships).each do |association|
        Bullet.add_safelist :type => :n_plus_one_query, :class_name => "Decidim::Proposals::Proposal", :association => association
      end
      %w(steps organization area scope active_step).each do |association|
        Bullet.add_safelist :type => :n_plus_one_query, :class_name => "Decidim::ParticipatoryProcess", :association => association
      end
      Bullet.add_safelist :type => :n_plus_one_query, :class_name => "Decidim::Component", :association => :participatory_space
      subject.perform_now(proposal, attributes, context)
      proposal.reload
    end

    it "updates the proposal answer" do
      expect(proposal.answer).to eq({ "en" => "Test answer" })
      expect(proposal.proposal_status).to eq(new_status)
    end

    context "when the answer is invalid" do
      let(:attributes) do
        {
          "answer" => { "en" => "Test answer" },
          "internal_status" => "a-status-that-does-not-exist"
        }
      end

      it "does not update the proposal answer" do
        expect(proposal.answer).not_to eq({ "en" => "Test answer" })
        expect(proposal.proposal_status).not_to eq(new_status)
      end
    end
  end
end
