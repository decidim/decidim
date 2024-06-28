# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalAnswerJob do
  let(:component) { create(:proposal_component, :with_creation_enabled) }
  let(:initial_state) { create(:proposal_state, component:, token: "initial_state") }
  let(:proposal) { create(:proposal, component:, proposal_state: initial_state) }
  let(:proposal_state) do
    create(
      :proposal_state,
      title: { en: "Custom state" },
      token: "custom_state",
      component:
    )
  end

  let(:answer_form_params) do
    {
      "answer" => { "en" => "Test answer" },
      "internal_state" => proposal_state.token,
      "cost" => "1000",
      "cost_report" => { "en" => "Cost report" },
      "execution_period" => { "en" => "Execution period" }
    }
  end

  describe "#perform" do
    context "when the answer is valid" do
      before do
        allow(Decidim::Proposals::Admin::AnswerProposal).to receive(:call) do |form, proposal|
          proposal.update!(answer: form.answer, proposal_state:)
          double(success?: true, invalid?: false)
        end
      end

      it "updates the proposal answer" do
        described_class.perform_now(proposal.id, answer_form_params, component)
        proposal.reload

        expect(proposal.answer).to eq({ "en" => "Test answer" })
      end

      it "updates the proposal state" do
        described_class.perform_now(proposal.id, answer_form_params, component)
        proposal.reload

        expect(proposal.proposal_state).to eq(proposal_state)
      end
    end

    context "when the answer is invalid" do
      let(:original_answer) { proposal.answer }
      let(:original_proposal_state) { proposal.proposal_state }

      before do
        allow(Decidim::Proposals::Admin::AnswerProposal).to receive(:call).and_return(double(success?: false, invalid?: true))
      end

      it "does not update the proposal answer" do
        described_class.perform_now(proposal.id, answer_form_params, component)
        proposal.reload

        expect(proposal.answer).to eq(original_answer)
      end

      it "does not update the proposal state" do
        described_class.perform_now(proposal.id, answer_form_params, component)
        proposal.reload

        expect(proposal.proposal_state).to eq(original_proposal_state)
      end
    end
  end
end
