# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Proposals::DataPortabilityProposalEndorsementSerializer do
    let(:subject) { described_class.new(resource) }
    let(:resource) { create(:proposal_endorsement) }

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

      it "includes the user group" do
        expect(serialized[:user_group]).to(
          include(id: resource.try(:user_group).try(:id))
        )
        expect(serialized[:user_group]).to(
          include(name: resource.try(:user_group).try(:name))
        )
      end
    end
  end
end
