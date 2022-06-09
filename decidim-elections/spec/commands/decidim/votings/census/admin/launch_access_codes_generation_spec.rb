# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe LaunchAccessCodesGeneration do
    subject { described_class.new(dataset, user) }

    let(:dataset) { create(:dataset, status: :data_created) }
    let(:user) { create(:user, :admin, organization: dataset.organization) }

    context "when the inputs are not valid" do
      context "when the user in nil" do
        let(:dataset) { create(:dataset) }
        let(:user) { nil }

        it { expect(subject).to broadcast(:invalid) }
      end

      context "when the is no datum in the dataset" do
        it { expect(subject).to broadcast(:invalid) }
      end

      context "when the dataset is not in the right status" do
        let(:dataset) { create(:dataset, status: :init_data) }

        it { expect(subject).to broadcast(:invalid) }
      end
    end

    context "when the inputs are valid" do
      let(:dataset) { create(:dataset, :with_data, :data_created) }

      it "updates the data" do
        expect(subject).to broadcast(:ok)

        expect(dataset.reload).to be_generating_codes
      end
    end
  end
end
