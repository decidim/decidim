# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Proposals::DataPortabilityProposalVoteSerializer do
    let(:subject) { described_class.new(resource) }
    let(:resource) { create(:proposal_vote) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the proposal" do
        expect(serialized[:proposal]).to(
          include(id: resource.proposal.id)
        )
        expect(serialized[:proposal]).to(
          include(title: resource.proposal.title)
        )
        expect(serialized[:proposal]).to(
          include(body: resource.proposal.body)
        )
      end
    end
  end
end
