# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe PollingOfficer do
      subject(:polling_officer) { build(:polling_officer, user:, voting:) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:voting) { create(:voting, organization:) }

      it { is_expected.to be_valid }

      context "when the voting is from another organization" do
        let(:other_organization) { create(:organization) }
        let(:voting) { create(:voting, organization: other_organization) }

        it { is_expected.not_to be_valid }
      end

      context "when the user is already present" do
        context "when in the same voting" do
          let!(:other_polling_officer) { create(:polling_officer, user:, voting:) }

          it { is_expected.not_to be_valid }
        end

        context "when in another voting" do
          let(:other_voting) { create(:voting, organization:) }
          let!(:other_polling_officer) { create(:polling_officer, user:, voting: other_voting) }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
