# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::CommitteeUserAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, :created, organization: organization) }
  let(:other_initiative) { create(:initiative, :created, organization: organization) }
  let(:user) { create(:user, :admin, organization: organization) }

  context "when manage promotal committee requests" do
    context "and initiative authors" do
      let(:user) { initiative.author }

      it "lets the user manage promotal committee requests" do
        expect(subject).to be_able_to(:manage_membership, initiative)
      end

      it "do not lets the user manage promotal committee requests on other users initiatives" do
        expect(subject).not_to be_able_to(:manage_membership, other_initiative)
      end
    end

    context "and initiative committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

      it "lets the user manage promotal committee requests" do
        expect(subject).to be_able_to(:manage_membership, initiative)
      end

      it "do not lets the user manage promotal committee requests on other users initiatives" do
        expect(subject).not_to be_able_to(:manage_membership, other_initiative)
      end
    end

    context "and regular users" do
      let(:user) { create(:user, organization: organization) }

      it "do not lets the user manage promotal committee requests" do
        expect(subject).not_to be_able_to(:manage_membership, initiative)
      end
    end
  end

  context "and list promotal committee requests" do
    context "and initiative authors" do
      let(:user) { initiative.author }

      it "lets the user list committee requests" do
        expect(subject).to be_able_to(:index, Decidim::InitiativesCommitteeMember)
      end
    end

    context "and initiative committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

      it "lets the user list committee requests" do
        expect(subject).to be_able_to(:index, Decidim::InitiativesCommitteeMember)
      end
    end

    context "and regular users" do
      let(:user) { create(:user, organization: organization) }

      it "do not lets the user list committee requests" do
        expect(subject).not_to be_able_to(:index, Decidim::InitiativesCommitteeMember)
      end
    end
  end

  context "and approve request" do
    context "and initiative author" do
      let(:user) { initiative.author }

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

    context "and committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

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

    context "and plain users" do
      let(:user) { create(:user, organization: organization) }

      it "do not lets the user approve unresponded requests" do
        request = create(:initiatives_committee_member, :requested, initiative: initiative)
        expect(subject).not_to be_able_to(:approve, request)
      end

      it "do not lets the user approve rejected requests" do
        request = create(:initiatives_committee_member, :rejected, initiative: initiative)
        expect(subject).not_to be_able_to(:approve, request)
      end

      it "do not lets the user approve approved requests" do
        request = create(:initiatives_committee_member, initiative: initiative)
        expect(subject).not_to be_able_to(:approve, request)
      end
    end
  end

  context "and reject request" do
    context "and initiative author" do
      let(:user) { initiative.author }

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

    context "and committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

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

    context "and plain users" do
      let(:user) { create(:user, organization: organization) }

      it "do not lets the user revoke unresponded requests" do
        request = create(:initiatives_committee_member, :requested, initiative: initiative)
        expect(subject).not_to be_able_to(:revoke, request)
      end

      it "do not lets the user revoke rejected requests" do
        request = create(:initiatives_committee_member, :rejected, initiative: initiative)
        expect(subject).not_to be_able_to(:revoke, request)
      end

      it "do not lets the user revoke approved requests" do
        request = create(:initiatives_committee_member, initiative: initiative)
        expect(subject).not_to be_able_to(:revoke, request)
      end
    end
  end
end
