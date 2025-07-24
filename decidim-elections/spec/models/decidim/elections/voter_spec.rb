# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Voter do
      subject { voter }

      let(:election) { create(:election) }
      let(:voter) { create(:election_voter, election:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has an association of election" do
        expect(subject.election).to eq(election)
      end

      describe "validations" do
        context "when data is missing" do
          let(:voter) { build(:election_voter, election:, data: {}) }

          it "is not valid" do
            expect(voter).not_to be_valid
          end
        end
      end

      describe "#identifier" do
        context "when data is a hash" do
          let(:voter) { build(:election_voter, election:, data: { identifier: "12345" }) }

          it "returns the identifier from data" do
            expect(voter.identifier).to eq("12345")
          end
        end

        context "when data is a string" do
          let(:voter) { build(:election_voter, election:, data: "some string data") }

          it "returns the truncated string" do
            expect(voter.identifier).to eq("some string data".truncate(50))
          end

          context "when data is empty" do
            let(:voter) { build(:election_voter, election:, data: nil) }

            it "returns the id" do
              expect(voter.identifier).to eq(voter.id)
            end
          end
        end
      end

      describe ".bulk_insert" do
        let(:values) { [{ identifier: "voter1" }, { identifier: "voter2" }] }

        it "creates voters with the provided data" do
          expect { described_class.bulk_insert(election, values) }
            .to change(described_class, :count).by(2)

          expect(described_class.last.data).to eq("identifier" => "voter2")
        end
      end
    end
  end
end
