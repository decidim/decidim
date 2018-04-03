# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::CommitteeAdminAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, :created, organization: organization) }
  let(:user) { create(:user, :admin, organization: organization) }

  it "lets the user manage promotal committee requests" do
    expect(subject).to be_able_to(:manage_membership, Decidim::Initiative)
  end

  it "lets the user list promotal committee requests" do
    expect(subject).to be_able_to(:index, Decidim::InitiativesCommitteeMember)
  end

  context "when approve request" do
    it "lets the user approve unresponded requests" do
      request = create(:initiatives_committee_member, :requested, initiative: initiative)
      expect(subject).to be_able_to(:approve, request)
    end

    it "lets the user approve rejected requests" do
      request = create(:initiatives_committee_member, :rejected, initiative: initiative)
      expect(subject).to be_able_to(:approve, request)
    end

    it "do not lets the user approve approved requests" do
      request = create(:initiatives_committee_member, initiative: initiative)
      expect(subject).not_to be_able_to(:approve, request)
    end
  end

  context "when reject request" do
    it "lets the user revoke unresponded requests" do
      request = create(:initiatives_committee_member, :requested, initiative: initiative)
      expect(subject).to be_able_to(:revoke, request)
    end

    it "do not lets the user revoke rejected requests" do
      request = create(:initiatives_committee_member, :rejected, initiative: initiative)
      expect(subject).not_to be_able_to(:revoke, request)
    end

    it "lets the user revoke approved requests" do
      request = create(:initiatives_committee_member, initiative: initiative)
      expect(subject).to be_able_to(:revoke, request)
    end
  end
end
