# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe StatusChangeNotifier do
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:organization) { create(:organization) }
      let(:author) { create(:user, organization:) }
      let(:created) { false }
      let(:validating) { false }
      let(:published) { false }
      let(:discarded) { false }
      let(:rejected) { false }
      let(:accepted) { false }
      let(:committee_members) { [] }
      let(:initiative) do
        double(
          "initiative",
          organization:,
          author:,
          created?: created,
          validating?: validating,
          published?: published,
          discarded?: discarded,
          rejected?: rejected,
          accepted?: accepted,
          committee_members: double("committee_members", approved: committee_members)
        )
      end

      subject { described_class.new(initiative:) }

      before do
        allow(message_delivery).to receive(:deliver_later)
      end

      context "when created" do
        let(:created) { true }

        it "Creation is notified" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_creation)
            .with(initiative)
            .once
            .and_return(message_delivery)
          subject.notify
        end
      end

      context "when published" do
        let(:published) { true }
        let(:committee_members) do
          members = []
          2.times do
            members << double(
              "committee_member",
              user: create(:user, organization:)
            )
          end
          members
        end

        it "Publication is notified to author and committee members" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .with(any_args)
            .exactly(3).times
            .and_return(message_delivery)
          subject.notify
        end
      end

      context "when discarded" do
        let(:discarded) { true }
        let(:committee_members) do
          members = []
          2.times do
            members << double(
              "committee_member",
              user: create(:user, organization:)
            )
          end
          members
        end

        it "Publication is notified to author and committee members" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .with(any_args)
            .exactly(3).times
            .and_return(message_delivery)
          subject.notify
        end
      end

      context "when rejected" do
        let(:rejected) { true }
        let(:committee_members) do
          members = []
          2.times do
            members << double(
              "committee_member",
              user: create(:user, organization:)
            )
          end
          members
        end

        it "Result is notified to the author" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .with(any_args)
            .exactly(4).times
            .and_return(message_delivery)
          subject.notify
        end
      end

      context "when accepted" do
        let(:accepted) { true }
        let(:committee_members) do
          members = []
          2.times do
            members << double(
              "committee_member",
              user: create(:user, organization:)
            )
          end
          members
        end

        it "Result is notified to the author" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_state_change)
            .with(any_args)
            .exactly(4).times
            .and_return(message_delivery)
          subject.notify
        end
      end
    end
  end
end
