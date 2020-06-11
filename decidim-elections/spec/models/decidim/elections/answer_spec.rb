# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Answer do
  subject(:answer) { build(:election_answer) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  describe "#proposals" do
    subject { answer.proposals }

    let(:answer) { create(:election_answer) }

    it { is_expected.to be_empty }

    context "when the answer has related proposals" do
      let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: answer.question.election.component.participatory_space }
      let(:proposals) { create_list :proposal, 2, component: proposals_component }
      let(:other_proposals) { create_list :proposal, 2 }

      before do
        other_proposals
        answer.link_resources(proposals, "related_proposals")
      end

      it { is_expected.to match_array(proposals) }
    end
  end
end
