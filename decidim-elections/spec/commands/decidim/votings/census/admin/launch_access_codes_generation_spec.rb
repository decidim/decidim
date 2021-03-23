# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe LaunchAccessCodesGeneration do
    subject { described_class.new(dataset, user) }

    let(:dataset) { create(:dataset, organization: user.organization, status: :review_data) }
    let(:user) { create(:user, :admin) }
    let!(:data) { create_list(:datum, 5, dataset: dataset) }

    context "when the inputs are not valid" do
      context "when the user in nil" do
        let(:dataset) { create(:dataset) }
        let(:user) {}

        it { expect(subject).to broadcast(:invalid) }
      end

      context "when the is no datum in the dataset" do
        let!(:data) { [] }

        it { expect(subject).to broadcast(:invalid) }
      end

      context "when the dataset is not in the right status" do
        let(:dataset) { create(:dataset, organization: user.organization, status: :export_codes) }

        it { expect(subject).to broadcast(:invalid) }
      end
    end

    context "when the inputs are valid" do
      let(:dataset) { create(:dataset, organization: user.organization, status: :review_data) }

      it "updates the data" do
        expect(subject).to broadcast(:ok)

        expect(dataset.reload).to be_generate_codes_status
      end
    end
  end
end
