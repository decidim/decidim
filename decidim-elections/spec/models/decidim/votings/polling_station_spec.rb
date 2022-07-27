# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe PollingStation do
      subject(:polling_station) { build(:polling_station, voting:, polling_station_managers: managers, polling_station_president: president) }

      let(:organization) { create(:organization) }
      let(:voting) { create(:voting, organization:) }
      let(:managers) { [] }
      let(:president) { nil }

      context "when no polling officers are assigned" do
        it { is_expected.to be_valid }
        it { is_expected.to be_versioned }
      end

      context "when a polling station president is assigned" do
        context "when the officer is from the same voting" do
          let(:president) { create(:polling_officer, voting:, user: create(:user, organization:)) }

          it "is valid" do
            expect(subject).to be_valid
            expect(subject.polling_station_president).to eq president
          end
        end

        context "when the officer is from another voting" do
          let(:other_voting) { create(:voting, organization:) }
          let(:president) { create(:polling_officer, voting: other_voting, user: create(:user, organization:)) }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when several polling station president is assigned" do
        let(:managers) { create_list(:polling_officer, 3, voting:) }

        it "is valid" do
          expect(subject).to be_valid
          expect(subject.polling_station_managers).to eq managers
        end
      end
    end
  end
end
