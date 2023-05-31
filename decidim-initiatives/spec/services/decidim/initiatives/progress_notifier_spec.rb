# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe ProgressNotifier do
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:organization) { create(:organization) }
      let(:author) { create(:user, organization:) }
      let(:followers) { [] }
      let(:approved_committee_members) { [] }
      let(:initiative) do
        double(
          "initiative",
          author:,
          followers:,
          committee_members: double("committee_members", approved: approved_committee_members)
        )
      end

      subject { described_class.new(initiative:) }

      before do
        allow(message_delivery).to receive(:deliver_later)
      end

      it "Author is notified" do
        expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_progress)
          .with(initiative, author)
          .once
          .and_return(message_delivery)
        subject.notify
      end

      context "and committee members are notified" do
        let(:committee_members_count) { 2 }
        let(:approved_committee_members) do
          members = []
          committee_members_count.times do
            members << double(
              "committe_member",
              user: create(:user, organization:)
            )
          end
          members
        end

        it "one message per committee member is sent" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_progress)
            .with(any_args)
            .exactly(committee_members_count + 1).times
            .and_return(message_delivery)

          subject.notify
        end
      end

      context "and followers are notified" do
        let(:followers_count) { 10 }
        let(:followers) do
          create_list(:user, followers_count, organization:)
        end

        it "one message per follower is sent" do
          expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_progress)
            .with(any_args)
            .exactly(followers_count + 1).times
            .and_return(message_delivery)

          subject.notify
        end
      end
    end
  end
end
