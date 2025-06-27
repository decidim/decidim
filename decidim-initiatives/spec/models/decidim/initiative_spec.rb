# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Initiative do
    subject { initiative }

    let(:organization) { create(:organization) }
    let(:initiative) { build(:initiative) }

    let(:initiatives_type_minimum_committee_members) { 2 }
    let(:initiatives_type) do
      create(
        :initiatives_type,
        organization:,
        minimum_committee_members: initiatives_type_minimum_committee_members
      )
    end
    let(:scoped_type) { create(:initiatives_type_scope, type: initiatives_type) }

    include_examples "has reference"

    context "when created initiative" do
      let(:initiative) { create(:initiative, :created) }
      let(:administrator) { create(:user, :admin, organization: initiative.organization) }
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:offline_type) { create(:initiatives_type, :online_signature_disabled, organization:) }
      let(:offline_scope) { create(:initiatives_type_scope, type: offline_type) }

      before do
        allow(message_delivery).to receive(:deliver_later)
      end

      it "is versioned" do
        expect(initiative).to be_versioned
      end

      it "enforces signature types specified in the type" do
        online_initiative = build(:initiative, :created, organization:, scoped_type: offline_scope, signature_type: "online")
        offline_initiative = build(:initiative, :created, organization:, scoped_type: offline_scope, signature_type: "offline")

        expect(online_initiative).to be_invalid
        expect(offline_initiative).to be_valid
      end

      it "Creation is notified by email" do
        expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_creation)
          .at_least(:once)
          .at_most(:once)
          .and_return(message_delivery)
        initiative = build(:initiative, :created)
        initiative.save!
      end
    end

    context "when published initiative" do
      let(:published_initiative) { build(:initiative) }
      let(:online_allowed_type) { create(:initiatives_type, :online_signature_enabled, organization:) }
      let(:online_allowed_scope) { create(:initiatives_type_scope, type: online_allowed_type) }

      it "is valid" do
        expect(published_initiative).to be_valid
      end

      it "does not enforce signature type if the type was updated" do
        initiative = build(:initiative, organization:, scoped_type: online_allowed_scope, signature_type: "online")

        expect(initiative.save).to be_truthy

        online_allowed_type.update!(signature_type: "offline")

        expect(initiative).to be_valid
      end

      it "unpublish!" do
        published_initiative.unpublish!

        expect(published_initiative).to be_discarded
        expect(published_initiative.published_at).to be_nil
      end

      it "signature_interval_defined?" do
        expect(published_initiative).to have_signature_interval_defined
      end

      context "when mailing" do
        let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

        before do
          allow(message_delivery).to receive(:deliver_later)
        end

        it "Acceptation is notified by email" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          published_initiative.accepted!
        end

        it "Rejection is notified by email" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          published_initiative.rejected!
        end
      end
    end

    context "when validating initiative" do
      let(:validating_initiative) do
        build(:initiative,
              state: "validating",
              published_at: nil,
              signature_start_date: nil,
              signature_end_date: nil)
      end

      it "is valid" do
        expect(validating_initiative).to be_valid
      end

      it "publish!" do
        validating_initiative.publish!
        expect(validating_initiative).to have_signature_interval_defined
        expect(validating_initiative.published_at).not_to be_nil
      end

      context "when mailing" do
        let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

        before do
          allow(message_delivery).to receive(:deliver_later)
        end

        it "publication is notified by email" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          validating_initiative.publish!
        end

        it "Discard is notified by email" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          validating_initiative.discarded!
        end
      end
    end

    context "when has_authorship?" do
      let(:initiative) { create(:initiative) }
      let(:user) { create(:user) }
      let(:pending_committee_member) { create(:initiatives_committee_member, :requested, initiative:) }
      let(:rejected_committee_member) { create(:initiatives_committee_member, :rejected, initiative:) }

      it "returns true for the initiative author" do
        expect(initiative).to have_authorship(initiative.author)
      end

      it "returns true for approved promotal committee members" do
        expect(initiative).not_to have_authorship(pending_committee_member.user)
        expect(initiative).not_to have_authorship(rejected_committee_member.user)

        expect(initiative.committee_members.approved).to be_any

        initiative.committee_members.approved.each do |m|
          expect(initiative).to have_authorship(m.user)
        end
      end

      it "returns false for any other user" do
        expect(initiative).not_to have_authorship(user)
      end
    end

    describe "signatures calculations" do
      let!(:initiative) { create(:initiative, signature_type:) }
      let(:scope_id) { initiative.scope.id.to_s }
      let!(:other_scope_for_type) { create(:initiatives_type_scope, type: initiative.type) }

      context "with only online initiatives" do
        let(:signature_type) { "online" }

        it "ignores any value in offline_votes attribute" do
          initiative.update(offline_votes: { scope_id => initiative.scoped_type.supports_required, "total" => initiative.scoped_type.supports_required },
                            online_votes: { scope_id => initiative.scoped_type.supports_required / 2, "total" => initiative.scoped_type.supports_required / 2 })
          expect(initiative.percentage).to eq(50)
          expect(initiative).not_to be_supports_goal_reached
        end

        it "cannot be greater than 100" do
          initiative.update(online_votes: { scope_id => initiative.scoped_type.supports_required, "total" => initiative.scoped_type.supports_required * 2 })
          expect(initiative.percentage).to eq(100)
          expect(initiative).to be_supports_goal_reached
        end
      end

      context "with face-to-face support too" do
        let(:signature_type) { "any" }

        it "returns the percentage of votes reached" do
          online_votes = initiative.scoped_type.supports_required / 4
          offline_votes = initiative.scoped_type.supports_required / 4
          initiative.update(offline_votes: { scope_id => offline_votes, "total" => offline_votes },
                            online_votes: { scope_id => online_votes, "total" => online_votes })
          expect(initiative.percentage).to eq(50)
          expect(initiative).not_to be_supports_goal_reached
        end

        it "cannot be greater than 100" do
          online_votes = initiative.scoped_type.supports_required * 4
          offline_votes = initiative.scoped_type.supports_required * 4
          initiative.update(offline_votes: { scope_id => offline_votes, "total" => offline_votes },
                            online_votes: { scope_id => online_votes, "total" => online_votes })
          expect(initiative.percentage).to eq(100)
          expect(initiative).to be_supports_goal_reached
        end
      end
    end

    describe "#minimum_committee_members" do
      subject { initiative.minimum_committee_members }

      let(:committee_members_fallback_setting) { 1 }
      let(:initiative) { create(:initiative, organization:, scoped_type:) }

      before do
        allow(Decidim::Initiatives).to(
          receive(:minimum_committee_members).and_return(committee_members_fallback_setting)
        )
      end

      context "when setting defined in type" do
        it { is_expected.to eq initiatives_type_minimum_committee_members }
      end

      context "when setting not set" do
        let(:initiatives_type_minimum_committee_members) { nil }

        it { is_expected.to eq committee_members_fallback_setting }
      end
    end

    describe "#enough_committee_members?" do
      subject { initiative.enough_committee_members? }

      let(:initiatives_type_minimum_committee_members) { 2 }
      let(:initiative) { create(:initiative, organization:, scoped_type:) }

      before { initiative.committee_members.destroy_all }

      context "when enough members" do
        before { create_list(:initiatives_committee_member, initiatives_type_minimum_committee_members, initiative:) }

        it { is_expected.to be true }
      end

      context "when not enough members" do
        before { create_list(:initiatives_committee_member, initiatives_type_minimum_committee_members - 1, initiative:) }

        it { is_expected.to be false }
      end
    end

    describe "#missing_committee_members" do
      subject { initiative.missing_committee_members }

      let(:initiatives_type_minimum_committee_members) { 2 }
      let(:initiative) { create(:initiative, organization:, scoped_type:) }

      before { initiative.committee_members.destroy_all }

      context "when all missing members" do
        it { is_expected.to be 2 }
      end

      context "when one missing member" do
        before { create(:initiatives_committee_member, initiative:) }

        it { is_expected.to be 1 }
      end

      context "when no missing members" do
        before { create_list(:initiatives_committee_member, initiatives_type_minimum_committee_members, initiative:) }

        it { is_expected.to be 0 }
      end
    end

    describe "sorting" do
      subject(:sorter) { described_class.ransack("s" => "supports_count desc") }

      before do
        create(:initiative, organization:, signature_type: "offline")
        create(:initiative, organization:, signature_type: "offline", offline_votes: { "total" => 4 })
        create(:initiative, organization:, signature_type: "online", online_votes: { "total" => 5 })
        create(:initiative, organization:, signature_type: "online", online_votes: { "total" => 3 })
        create(:initiative, organization:, signature_type: "any", online_votes: { "total" => 1 })
        create(:initiative, organization:, signature_type: "any", online_votes: { "total" => 5 }, offline_votes: { "total" => 3 })
      end

      it "sorts initiatives by supports count" do
        expect(sorter.result.map(&:supports_count)).to eq([8, 5, 4, 3, 1, 0])
      end
    end
  end
end
