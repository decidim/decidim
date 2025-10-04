# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Censuses
      describe TokenCsvForm do
        let(:election) { create(:election, :ongoing, :with_token_csv_census) }
        let!(:voter) { create(:election_voter, data:, election:) }
        let(:organization) { election.organization }

        let(:params) do
          {
            email: "bob@example.org",
            token: "1234567890"
          }
        end
        let(:data) do
          {
            email: "bob@example.org",
            token: "1234567890"
          }
        end

        subject { described_class.from_params(params).with_context(election:) }

        it { is_expected.to be_valid }

        describe "#voter_uid" do
          it "returns the global ID of the voter in the census" do
            expect(subject.voter_uid).to eq(voter.to_global_id.to_s)
          end
        end

        context "when the voter is not in the census" do
          let(:params) { { email: "alice@example.org", token: "1234567890" } }

          it { is_expected.not_to be_valid }

          it "returns nil" do
            expect(subject.voter_uid).to be_nil
          end
        end

        context "when voter in another election" do
          let(:other_election) { create(:election, :ongoing, :with_token_csv_census) }
          let!(:voter) { create(:election_voter, data:, election: other_election) }

          it { is_expected.not_to be_valid }

          it "does not return the voter from another election" do
            expect(subject.voter_uid).to be_nil
          end
        end
      end
    end
  end
end
