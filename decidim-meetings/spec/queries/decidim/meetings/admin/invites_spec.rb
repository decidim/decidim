# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Admin
  describe Invites do
    subject { described_class.for(Decidim::Meetings::Invite.all, search, filter) }

    let(:organization) { create :organization }
    let(:search) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:invites) { create_list(:invite, 3) }

      it "returns all invites" do
        expect(subject).to match_array invites
      end
    end

    describe "when the list is filtered" do
      context "and receives a search param" do
        let(:invites) do
          %w(Walter Fargo Phargo).map do |name|
            create(:invite, user: create(:user, name:))
          end
        end

        context "with regular characters" do
          let(:search) { "Argo" }

          it "returns all matching invites" do
            expect(subject).to match_array([invites[1], invites[2]])
          end
        end

        context "with conflictive characters" do
          let(:search) { "Andy O'Connel" }

          it "returns all matching users" do
            expect(subject).to be_empty
          end
        end
      end

      context "and receives a filter param" do
        let!(:sent_invites) { create_list(:invite, 2) }
        let!(:accepted_invites) { create_list(:invite, 4, :accepted) }
        let!(:rejected_invites) { create_list(:invite, 4, :rejected) }

        context 'when the user filters by "Sent"' do
          let(:filter) { "sent" }

          it "returns all the sent invites, not accepted or rejected" do
            expect(subject).to match_array(sent_invites)
          end
        end

        context 'when the user filters by "Accepted"' do
          let(:filter) { "accepted" }

          it "returns all the accepted invites" do
            expect(subject).to match_array(accepted_invites)
          end
        end

        context 'when the user filters by "Rejected"' do
          let(:filter) { "rejected" }

          it "returns all the rejected invites" do
            expect(subject).to match_array(rejected_invites)
          end
        end
      end

      context "and receives search and filter params at a time" do
        let(:accepted_invites) do
          %w(Lorem Ipsum Dolor).map do |name|
            create(:invite, :accepted, user: create(:user, name:))
          end
        end

        let(:search) { "lo" }
        let(:filter) { "accepted" }

        it 'returns the "Accepted" invites matching the query search' do
          expect(subject).to match_array([accepted_invites[0], accepted_invites[2]])
        end
      end
    end
  end
end
