# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Initiative do
    context "when created initiative" do
      let(:initiative) { create(:initiative, :created) }
      let(:administrator) { create(:user, :admin, organization: initiative.organization) }
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

      before do
        allow(message_delivery).to receive(:deliver_later)
      end

      it "is versioned" do
        expect(initiative).to be_versioned
      end

      it "technical revission request is notified by email" do
        expect(administrator).not_to be_nil
        expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_validating_request)
          .at_least(:once)
          .and_return(message_delivery)
        initiative.validating!
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
      let(:published_initiative) { build :initiative }

      it "is valid" do
        expect(published_initiative).to be_valid
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
          validating_initiative.published!
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
      let(:pending_committee_member) { create(:initiatives_committee_member, :requested, initiative: initiative) }
      let(:rejected_committee_member) { create(:initiatives_committee_member, :rejected, initiative: initiative) }

      it "returns true for the initiative author" do
        expect(initiative).to have_authorship(initiative.author)
      end

      it "returns true for aproved promotal committee members" do
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

    context "when percentage" do
      context "and online initiatives" do
        let!(:initiative) { create(:initiative) }

        it "ignores any value in offline_votes attribute" do
          initiative.update(offline_votes: 1000, initiative_votes_count: initiative.scoped_type.supports_required / 2)
          expect(initiative.percentage).to eq(50)
        end

        it "can't be greater than 100" do
          initiative.update(initiative_votes_count: initiative.scoped_type.supports_required * 2)
          expect(initiative.percentage).to eq(100)
        end
      end

      context "and face-to-face support" do
        let!(:initiative) { create(:initiative, signature_type: "any") }

        it "returns the percentage of votes reached" do
          online_votes = initiative.scoped_type.supports_required / 4
          offline_votes = initiative.scoped_type.supports_required / 4
          initiative.update(offline_votes: offline_votes, initiative_votes_count: online_votes)
          expect(initiative.percentage).to eq(50)
        end

        it "can't be greater than 100" do
          online_votes = initiative.scoped_type.supports_required * 4
          offline_votes = initiative.scoped_type.supports_required * 4
          initiative.update(offline_votes: offline_votes, initiative_votes_count: online_votes)
          expect(initiative.percentage).to eq(100)
        end
      end
    end
  end
end
