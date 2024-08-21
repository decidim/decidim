# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalAnswerJob do
  subject { described_class }

  let(:component) { create(:proposal_component, :with_creation_enabled) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:old_state) { create(:proposal_state, component:, token: "old_state") }
  let(:proposal) { create(:proposal, component:, proposal_state: old_state) }
  let(:new_state) do
    create(
      :proposal_state,
      title: { en: "Custom state" },
      token: "custom_state",
      component:
    )
  end

  let(:attributes) do
    {
      "answer" => { "en" => "Test answer" },
      "internal_state" => new_state.token
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
      subject.perform_now(proposal, attributes, context)
      proposal.reload
    end

    it "updates the proposal answer" do
      expect(proposal.answer).to eq({ "en" => "Test answer" })
      expect(proposal.proposal_state).to eq(new_state)
    end

    context "when the answer is invalid" do
      let(:attributes) do
        {
          "answer" => { "en" => "Test answer" },
          "internal_state" => "a-state-that-does-not-exist"
        }
      end

      it "does not update the proposal answer" do
        expect(proposal.answer).not_to eq({ "en" => "Test answer" })
        expect(proposal.proposal_state).not_to eq(new_state)
      end
    end
  end
end
